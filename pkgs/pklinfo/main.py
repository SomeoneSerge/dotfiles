from argparse import ArgumentParser
from pathlib import Path
from pprint import pprint

parser = ArgumentParser("pklinfo")
parser.add_argument("path", type=Path)
parser.add_argument("--allow-pickle", action="store_true")
parser.add_argument("--kind", default="numpy", choices=["numpy", "torch"])


def is_array(a):
    return all(hasattr(a, attr) for attr in ["shape", "dtype", "__getitem__"])


def is_dict(a):
    # fmt: off
    return all([
        not is_array(a),
        hasattr(a, "__getitem__"),
        hasattr(a, "__iter__")
    ])
    # fmt: on


def describe(a):
    if is_array(a):
        shape = tuple(int(i) for i in a.shape)
        dtype = str(a.dtype)
        return f"array: {shape} => {dtype}"
    elif is_dict(a):
        return {name: describe(a[name]) for name in a}
    else:
        return type(a).__name__


def main(args):

    if args.kind == "torch":
        import torch

        a = torch.load(args.path, map_location="cpu")
    elif args.kind == "numpy":
        import numpy as np

        a = np.load(args.path, allow_pickle=args.allow_pickle)
    else:
        parser.error("Unknown --kind")

    pprint(describe(a))


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
