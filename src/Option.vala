
namespace VUnit.Runner{

    internal class Option : Object{

        internal string[] syntax { get; private set; }
        internal string description { get; private set; }

        internal Option(string[] syntax, string description, bool optional = false){
            this.syntax = syntax;
            this.description = description;
        }

    }

}
