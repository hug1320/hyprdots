function proxy7
 ssh -N -D 0.0.0.0:1080 -q -C -N root@titan.inpt.fr & disown; 
end
