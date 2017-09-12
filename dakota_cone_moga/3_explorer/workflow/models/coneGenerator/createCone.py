import math
import sys
from stl import mesh
import numpy as np

# Reading cone radius and height
line = sys.argv[1]
# Reading name of .txt file containing cone's volume and lateral area
txtFileName=sys.argv[2]
# Reading name of the .stl file with the cone's geometry
stlFileName=sys.argv[3]

# Reading cone radius and height 
line=line.replace(',', ' ').replace(':', ' ')
words=line.split(' ')
k=0
for word in words:
   if word=="height":
     h=float(words[k+1])
   elif word=="radius":
     r=float(words[k+1])
   k=k+1  

# Writing cone volume and lateral area
f = open(txtFileName, 'w')
#Inputs r ad h
volume = (math.pi/3)*r*r*h
s = math.sqrt(r*r + h*h)
lateral = math.pi*r*s
base = math.pi*r*r
total_area = base + lateral
s0 = str(lateral)
s2 = str(volume)
s4 = str(total_area)
f.write(s0)
f.write(" ")
f.write(s2)
f.write(" ")
f.write(s4)
f.write(" ")
f.close()
########################
# Calculating vertices #
########################
# Cone's base will be centered in (0,0,0) with its axis align with the z-axis
nSides=36
nVerts=nSides+1+2 #+2 due to upper and lower axis points
# List of vertices
verts=np.zeros((nVerts,3),dtype=np.double)
verts[0,:]=[0,0,0] # Center vertex
verts[1,:]=[0,0,h] # Upper vertex
# Vertices along the base's perimeter
i=0
for v in range(2,nVerts):
   ang=i*(2*math.pi)/nSides
   verts[v,:]=[r*math.cos(ang),r*math.sin(ang),0]
   i=i+1
########################
# Defining faces       #
########################
# The cone cone will have 2*nSides faces. Each pair of points
# along the perimeter of the base is joined to the center point
# and the upper points
faces=np.zeros((2*nSides,3), dtype=np.integer)
for side in range(nSides):
   faces[side]=[side+2,side+3,0]
   faces[side+nSides]=[side+2,1,side+3]
# Create the mesh
cube = mesh.Mesh(np.zeros(faces.shape[0], dtype=mesh.Mesh.dtype))
for i, f in enumerate(faces):
    for j in range(3):
        cube.vectors[i][j] = verts[f[j],:]
# Write the mesh to file "cone.stl"
cube.save(stlFileName)
