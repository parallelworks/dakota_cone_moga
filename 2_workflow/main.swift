# Cone generator parameter sweep
type file;
############################################
# ------ INPUT / OUTPUT DEFINITIONS -------#
############################################

# workflow inputs
# comment this line out when running under dakota
file params         <arg("paramFile","params.run")>; 

# other inputs
string outdir      = "results/"; # Directory where the outputs are saved
string casedir     = strcat(outdir,"case"); # Directory where the outputs for each case are saved

# add models
# Directory containing the metrics extractor (mex) and design explorer (dex) related scripts and required files
file[] mexdex       <Ext;exec="utils/mapper.sh",root="models/mexdex">;
# Directory containing the cone generation model scripts
file[] coneGen       <Ext;exec="utils/mapper.sh",root="models/coneGenerator">;

# workflow outputs
file outhtml        <arg("html","results/output.html")>;# path to the output
file outcsv         <arg("csv","results/output.csv")>; 
string path        = toString(@java("java.lang.System","getProperty","user.dir"));

##############################
# ---- APP DEFINITIONS ----- #
##############################
# Combines the parameters in params.run to produce all the cases
app (file out) prepInputs (file params, file s[])
{
  python "models/mexdex/prepinputs.py" @params @out; 
}

app (file volAndLat, file csvFile, file pngFile, file so, file se) createCone (string heightAndRadius, file[] coneGen, file[] mexdex)
{
  bash "models/coneGenerator/createCone.sh" heightAndRadius @volAndLat @csvFile @pngFile stdout=@so stderr=@se;
}

# Produces a cvs list relating inputs (radius and height) to outputs (volume and lateral area) and the mesh image.
# Produces the html file for visualization and organization of results
app (file outcsv, file outhtml, file so, file se) postProcess (file[] t, string rpath, file caselist, file[] mexdex) {
  bash_pp "models/mexdex/postprocess.sh" filename(outcsv) filename(outhtml) rpath stdout=filename(so) stderr=filename(se);
}

######################
# ---- WORKFLOW ---- #
######################

file caselist <"cases.list">;

# comment this line out when running under dakota
caselist = prepInputs(params, mexdex);

# In built function to read each line in caselist into an array of strings
string[] cases = readData(caselist);

tracef("\n%i Cases in Simulation\n\n",length(cases));

# For each case computes the cone geometry and its metrics
file[] metrics;
foreach heightAndRadius,i in cases{
    trace(i,heightAndRadius);
    # generate the geometry step file
    file volAndLat     <strcat(casedir,"_",i,"/volAndLat.txt")>;
    file stlFile     <strcat(casedir,"_",i,"/cone.stl")>;
    file csvFile     <strcat(casedir,"_",i,"/metrics.csv")>; # csvFile and pngFile must be on the dame folder
    file pngFile     <strcat(casedir,"_",i,"/out_","cone.png")>; # The name of this file depends on kpi.json
    file cco 	            <strcat("logs/case_",i,"/createCone.out")>;
    file cce         	      <strcat("logs/case_",i,"/createCone.err")>;
    (volAndLat,csvFile,pngFile,cco,cce)=createCone(heightAndRadius,coneGen,mexdex);
    metrics[i]=volAndLat;
}
# For all cases creates a csv list and html file for visualization and organization of results
file spout <"logs/post.out">;
file sperr <"logs/post.err">;
(outcsv,outhtml,spout,sperr) = postProcess(metrics,path,caselist,mexdex);
