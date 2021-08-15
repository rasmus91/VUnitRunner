
namespace VUnit.Runner{

    internal class TestCaseInfo : Object{

        internal static Gee.List<GI.FunctionInfo> sfunc;
        internal static int currentindex = -1;
        internal weak TestSuiteInfo parent;
        internal static int[] hest = { 327, 222 };
        internal TestFixtureFunc test;
        internal TestFixtureFunc set_up = (v) => { currentindex++; };
        private GI.FunctionInfo _test_method;
        internal GI.FunctionInfo test_method {
            get{
                return this._test_method;
            }
        }
        internal string method_name {
            get{
                return this.test_method.get_name();
            }
        }

        static construct{
            sfunc = new Gee.ArrayList<GI.FunctionInfo>();
        }

        internal TestCaseInfo (string method_name, TestSuiteInfo parent){
            this.parent = parent;
            this.configure_delegate(method_name);

        }

        private void configure_delegate(string method_name){
            var objArg = GI.Argument();
            objArg.v_pointer = (void*)this.parent.instance;

            var method = ((GI.ObjectInfo)this.parent.registered_type).find_method(method_name);
            

            this._test_method = method;
            sfunc.add(method);
            var t = 1;
            this.test = (v) => {
                message("pre-test");
                message("int %d", hest[t]);
                sfunc.get(currentindex).invoke({ objArg }, {}, GI.Argument());
                message("post-test");
            };

        }

        internal TestCase create_test_case(){
            var method = ((GI.ObjectInfo)this.parent.registered_type).find_method(method_name);

            return new TestCase(
                this.test_method.get_name(),
                this.set_up,
                this.test,
                this.parent.tear_down
            );
        }

    }

}
