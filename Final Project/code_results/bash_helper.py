import sys
from train_test_run import complete_run

if __name__ == "__main__":
    model_name = str(sys.argv[1])
    
    print(f"\n\n### Currently Running Test with Model {model_name} ###\n\n")
    
    complete_run(model_name)
