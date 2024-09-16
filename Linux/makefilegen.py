import sys

def genmakefile(makefiledir,element):
    with open("MakefileStructure","r") as makein, open(makefiledir, 'w+') as makeout:
        r = makein.readlines()
        for line in r:
            makeout.write(line.replace("leds",element))

        makein.close()
        makeout.close()



if __name__ == "__main__":
    if len(sys.argv) == 3:
        genmakefile(sys.argv[1],sys.argv[2])
