using VUnit;

namespace VUnit.Runner{

    internal class TestSuiteInfo : Object{

        internal GI.RegisteredTypeInfo registered_type { get; private set; }
        internal Type object_type;

        internal static Object instance { get; private set; }

        private TestSuite _test_suite;

        internal TestSuite test_suite { 
            get{
                return this._test_suite;
            } 
        }

        internal int testindex = 1;

        internal TestFixtureFunc set_up;
        internal TestFixtureFunc tear_down;
        internal Gee.List<TestCaseInfo> tests { get; private set; }

        internal TestSuiteInfo(GI.ObjectInfo info, string method_name_pattern = "test_[\\w\\d_]*"){
            this.registered_type = (GI.RegisteredTypeInfo)info;
            this.object_type = registered_type.get_g_type();
            this.object_type.ensure();
            instance = Object.new(this.object_type);
            this.register_fixture_functions(info);
            this.register_test_functions(info);
        }

        private void register_fixture_functions(GI.ObjectInfo objectInfo){

            var objArg = GI.Argument();
            objArg.v_pointer = (void*)instance;

            var setup = objectInfo.find_method("set_up");
            this.set_up = (v) => { setup.invoke({ objArg }, { }, GI.Argument()); message("postsetup"); };

            var teardown = objectInfo.find_method("tear_down");
            this.tear_down = (v) => { teardown.invoke({ objArg }, { }, GI.Argument()); };

        }

        private void register_test_functions(GI.ObjectInfo objectinfo, string method_name_pattern = "test_[\\w\\d_]*"){
            this.tests = new Gee.ArrayList<TestCaseInfo>();
            for (var i = 0; i < objectinfo.get_n_methods(); i++){
                var method = objectinfo.get_method(i);
                if(
                    method.get_flags() != GI.FunctionInfoFlags.IS_CONSTRUCTOR
                    && !Regex.match_simple("^set_up$|^tear_down$", method.get_name())
                    && Regex.match_simple(method_name_pattern, method.get_name())
                ){
                    var caseInfo = new TestCaseInfo(method.get_name(), this);
                    this.tests.add(caseInfo);
                }
            }
        }

        internal TestSuite create_test_suite(){
            var suite = new TestSuite(this.registered_type.get_name());
            message("we have %d tests", this.tests.size);

            foreach(var testInfo in this.tests){
                var testCase = testInfo.create_test_case();
                suite.add(testCase);
            }

            return suite;
        }

    }

}
