{ writers, python3Packages }:

writers.writePython3Bin "pklinfo"
{
  libraries = with python3Packages; [
    pytorch
  ];
}
  (builtins.readFile ./main.py)
