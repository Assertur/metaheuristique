# metaSPPstu: solving the Set Packing Problem (student version)
Implementation in Julia (compliant Julia v1.x) of tools related to the Set Packing Problem (SPP) for pedagogical purposes.

This implementation is the base of an exercice of the course "metaheuristics".

------

Fonctionnalités des codes :

Eléments de soutien à l'implémentation en Julia v1.x des devoirs maison à réaliser dans le cadre du cours "métaheuristiques" en master 1 informatique". Révision pour l'année académique 2023-2024.

- `loadSPP.jl` : lecture d'une instance de SPP au format OR-library
- `setSPP.jl` : construction d'un modèle JuMP de SPP
- `getfname.jl`: collecte les noms de fichiers non cachés présents dans un répertoire donné
- `experiment.jl`: protocole pour mener une expérimentation numérique avec sorties graphiques

------

Le répertoire `Data` contient une sélection d'instances numériques de SPP au format OR-library :
- didactic.dat
- pb_100rnd0100.dat
- pb_100rnd300.dat
- pb_200rnd0100.dat
- pb_200rnd0300.dat
- pb_500rnd0100.dat
- pb_500rnd0400.dat
- pb_1000rnd0100.dat
- pb_1000rnd0300.dat
- pb_2000rnd0100.dat
- pb_2000rnd0500.dat

------

Dépendances à intaller  :
- import Pkg; Pkg.add("ArgParse")
- import Pkg; Pkg.add("PyPlot")
- import Pkg; Pkg.add("Combinatorics")
- import Pkg; Pkg.add("GLPK")
- import Pkg; Pkg.add("JuMP")

------

Exemple d'utilisation (`main.jl`) avec chemins d'accès correspondant à une configuration standard sur macOS :

julia main.jl --method grasp --instance didactic.dat --plot


main.jl [--method METHOD] [-i INSTANCE] [--plot] [-h]

optional arguments:

  --method METHOD       Method to run: greedy / grasp / reactive / pr
                        / aco / all (default: "all")
                        
  -i, --instance INSTANCE
                        Filename in ./Data/ (default: "all")
                        
  --plot                Generate plots
  
  -h, --help            show this help message and exit

------

Exemple d'utilisation (`experiment.jl`) du protocole d'expérimentation sur un GRASP-SPP simulé :

![terminal](https://github.com/xgandibleux/meta2017/blob/master/doc/terminal.jpg)

![run](https://github.com/xgandibleux/meta2017/blob/master/doc/Examen_d'un_run.jpg)

![analyse](https://github.com/xgandibleux/meta2017/blob/master/doc/bilan_tous_runs.jpg)

![cput](https://github.com/xgandibleux/meta2017/blob/master/doc/bilan_CPUt_tous_runs.jpg)

