# SAOExtractor
MATLAB Function to read SAO files (format 4.3) that contains ionosonde parameters.

USAGE:

SAOstruct=SAOExtractor(FILENAME) 
where FILENAME is the name of the file. Its output is a structure variable with
all the information available in the archive. Each field is created when is available, with a maximum of 60 
(see Table 1 on https://ulcar.uml.edu/~iag/SAO-4.3.htm) and a minimum of 4. The "Scaled" field contains all the
49 scaled parameters.
