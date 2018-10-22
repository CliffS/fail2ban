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
            temp = pickle.load(sys.stdin.buffer)
            # sys.stderr.write(">>" + str(temp) + "\n")
            result = json.dumps(temp)
            print(result)
        elif argv[0] == 'dump':
            pickle.dump(json.load(sys.stdin), sys.stdout.buffer, 1)
        else:
            sys.exit(2)
    except Exception as error:
        # sys.stderr.write("Exception in " + argv[0] + "\n")
        print(temp)
        sys.exit(3)

if __name__ == '__main__':
    main(sys.argv[1:])

