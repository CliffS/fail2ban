import sys
try:
    import simplejson as json
except ImportError:
    import json
try:
    import cPickleZ as pickle
except ImportError:
    import pickle

def main(argv):
    try:
        if argv[0] == 'load':
            json.dump(pickle.load(sys.stdin.buffer), sys.stdout)
        elif argv[0] == 'dump':
            pickle.dump(json.load(sys.stdin), sys.stdout.buffer, 1)
        else:
            sys.exit(2)
    except RuntimeError as error:
        sys.stdout.write(error)
        sys.exit(1)

if __name__ == '__main__':
    main(sys.argv[1:])

