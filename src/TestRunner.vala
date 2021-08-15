using VUnit;
using GI;

namespace VUnit.Runner{

    errordomain RunnerError{
        NAMESPACE_NOT_SPECIFIED,
        TYPELIB_NOT_FOUND,
        SHARED_LIB_NOT_FOUND,
    }

    public class TestRunner : Object{
        internal HashTable<string, Option> options;
        internal Repository repository;

        public static int main(string[] args){
            var runner = new TestRunner();
            //next line must be changed when i find out why VUnit can't be loaded from /usr/local/lib automatically
            /*runner.repository.require_private("/usr/local/lib/x86_64-linux-gnu/girepository-1.0", "VUnit", null, 0);
            var tbinfo = (RegisteredTypeInfo)runner.repository.find_by_name("VUnit", "TestBase");
            var tbtype = tbinfo.get_g_type();*/
            //runner.repository.require("Gtk", null, 0);
            string test_namespace = null;
            string? path = runner.get_path(args);
            message("GLib %u.%u", GLib.Version.MAJOR, GLib.Version.MINOR);
            //Get namespace and path from args
            try{
                test_namespace = runner.get_namespace(args);
            }catch(RunnerError.NAMESPACE_NOT_SPECIFIED err){
                stdout.printf("A namespace for the test runner to work with need to be specified by using: \n    -n <namespace>\n    --namespace <namespace>\n");
                return 1;
            }

            //Firstly, 'require' (load) the library in question, if path is set, do a private require
            if(path == null){
                try{
                    runner.repository.require(test_namespace, null, 0);
                    runner.print_rep_info(test_namespace);
                }catch(Error err){
                    stdout.printf("\nFailed to load namespace: %s, error message is: %s\n", test_namespace, err.message);
                    return 2;
                }
            }else{
                try{
                    message("Trying to find: %s, in: %s".printf(test_namespace, path));
                    runner.repository.require_private(path, test_namespace, null, 0);
                    runner.repository.prepend_library_path("/home/rasmus/Projekter/vala/VUnit/build/vunit/sample");
                    message("found ya!");

                    var strArg = new string[1];
                    strArg[0] = args[0];
                    unowned string[] ustrArg = strArg;
                    GLib.Test.init(ref ustrArg);


                    var root = GLib.TestSuite.get_root();

                    var class_infos = runner.get_test_classes(test_namespace);
                    var suite = runner.build_test_suite(test_namespace, class_infos);


                    root.add_suite(suite);

                    GLib.Test.run();

                }catch(Error err){
                    stdout.printf("\nFailed to load namespace: %s, with Typelib in: %s, error was: %s\n", test_namespace, path, err.message);
                    return 2;
                }
            }
            //discover all classes based on VUnit.TestBase
            


            //add all methods in each of the discovered classes with name matching (test_*|fact_*|theory_*) to tests

            //run all unit tests

            return 0;
        }

        construct{
            this.repository = Repository.get_default();
            this.options = new HashTable<string, Option>(
                (key) => { return key.hash(); }, 
                (a, b) => {return a == b; });

            this.options.@set("namespace", new Option(
                {"-n", "--namespace"},
                "The namespace containing the unit tests, this should be part of a shared library"
            ));

            this.options.@set("path", new Option(
                {"-p", "--path"},
                "The path containing the typelib, if not set, this will default to the PATH, where shared libraries are also found",
                true
            ));
        }


        private string? get_argument(string option_name, string[] args){
            var option = options.@get(option_name);

            if(option != null){
                var pattern = string.joinv("|", option.syntax);
                MatchInfo match;
                Regex rex = new Regex(pattern);
                for(var i = 1; i < args.length; i++){
                    if(rex.match(args[i], 0, out match)){
                        string? result = i + 1 < args.length ? args[i+1] : null;
                        return result;
                    }
                }

            }

            return null;
        }

        private string get_namespace(string[] args) throws RunnerError{
            var val = get_argument("namespace", args);
            if(val == null){
                throw new RunnerError.NAMESPACE_NOT_SPECIFIED("test 1.2.3..");
            }
            return (string)val;
        }

        private string? get_path(string[] args){
            return get_argument("path", args);
        }

        private bool object_is_testbase(BaseInfo info){
            var ri = (RegisteredTypeInfo) info;
            var gtype = ri.get_g_type();
            return gtype.is_a(typeof(VUnit.TestBase));
        }

        private Gee.List<FunctionInfo> get_testclass_testmethods(ObjectInfo info, string method_name_pattern = "test_[\\w\\d_]*"){
            var tests = new Gee.ArrayList<FunctionInfo>();
            for (int i = 0; i < info.get_n_methods(); i++){
                var test = info.get_method(i);
                if (
                    test.get_flags() == GI.FunctionInfoFlags.IS_METHOD
                    && Regex.match_simple(method_name_pattern, test.get_name())
                ){
                    tests.add(test);
                }
            }
            return tests;
        }

        private Gee.List<TestSuiteInfo> get_test_classes(string test_namespace, string class_name_pattern = "[\\w\\d]*Test"){
            var infos = new Gee.ArrayList<TestSuiteInfo>();
            for(var i = 0; i < this.repository.get_n_infos(test_namespace); i++){
                var info = this.repository.get_info(test_namespace, i);
                if ( info.get_type() == InfoType.OBJECT
                    && this.object_is_testbase(info)
                    &&  Regex.match_simple(class_name_pattern, info.get_name())) {
                    infos.add(new TestSuiteInfo((GI.ObjectInfo)info));
                }
            }

            return infos;
        }


        private void libInfo(string _namespace){
            this.repository.prepend_library_path("/home/rasmus/Projekter/vala/VUnit/build/vunit/sample");
            message(this.repository.get_shared_library(_namespace));

        }

        private void print_rep_info(string _namespace){
            this.repository.prepend_library_path("/home/rasmus/Projekter/vala/VUnit/build/vunit/sample");

            int infos = this.repository.get_n_infos(_namespace);
            string classes[] = {};
            for (int i = 0; i < infos; i++){
                BaseInfo info = repository.get_info(_namespace, i);
                //var ri = (RegisteredTypeInfo)info;
                //var type = ri.get_g_type();
                //message(info.get_name());

                if (info.get_type() == InfoType.OBJECT){
                    ObjectInfo si = (ObjectInfo) info;
                    RegisteredTypeInfo rtinfo = (RegisteredTypeInfo)info;
                    Type gtype = rtinfo.get_g_type();
                    gtype.ensure();
                    Object obj = Object.new(gtype);

                    for (int j = 0; j < si.get_n_methods(); j++){
                        var meth = si.get_method(j);
                        if(meth.get_flags() == GI.FunctionInfoFlags.IS_METHOD){
                            message("%s with %d args".printf(meth.get_name(), meth.get_n_args()));
                            for (int a = 0; a < meth.get_n_args(); a++){
                                var argN = meth.get_arg(a);
                                message(argN.get_type().get_name());
                            }
                            message(meth.get_flags().to_string());
                            TestFixtureFunc test_methoed = (h) => {
                                message("hey");
                            };
                            var arg = GI.Argument();
                            arg.v_pointer = (void*)&obj;
                            meth.invoke({ arg },{ }, Argument());
                        }
                    }


                }
            }
        }

        private TestSuite build_test_suite(string _namespace, Gee.List<TestSuiteInfo> infos){
            var root = new TestSuite(_namespace);
            foreach (var info in infos){
                root.add_suite(info.create_test_suite());
            }
            return root;
        }

    }

}
