(* Sua implementação deverá estar neste arquivo.  *)

class Stack {
	top () : String {
		{ "%"; }
	};
	stack () : Stack {
		{ self; }
	};
	push (new_item : String) : Stack {
		(new Push).insert(new_item, self)
	};
	pop () : Stack{
		(new Pop).remove(self.top(), self.stack())
	};
};

class Push inherits Stack {
	new_element : String;
	stack_content : Stack;
	top() : String {
		new_element
	};
	stack() : Stack {
		stack_content
	};
	insert(new_item : String, rest_of_stack : Stack) : Stack {
		{
			new_element <- new_item;
			stack_content <- rest_of_stack;
			self; (* return *)
		}
	};
};

class Pop inherits Stack {
	new_top_element : String;
	stack_content : Stack;
	top() : String {
		new_top_element
	};
	stack() : Stack {
		stack_content
	};
	remove(item_to_remove : String, rest_of_stack : Stack) : Stack {
		{
			new_top_element <- rest_of_stack.top();
			stack_content <- rest_of_stack.stack();
			self; (* return *)
		}
	};
};
(*
class StackCommand {
	command : String;

	init (string : String) : StackCommand{
		{
			command <- string;
			self;
		}
	};

	value() : String {
		command
	};
};

class StackInt inherits StackCommand {
	integer : Int;

	init (n : Int) : StackCommand {
		{
			integer <- n;
			self;
		}
	};

	value() : Int {
		integer
	};
};

class StackSum inherits StackCommand {
	
};

class StackSwap inherits StackCommand {

};

class StackEvaluate inherits StackCommand {

};

class Stack
*)
class Main inherits IO {
	stop : Bool <- false;

	

	string : String;

	main() : Object {
		{
			while (not stop) Loop {
				out_string(">");
				string <- in_string();
				if (string = "x")
					then stop <- true
				else {
					if (string = "+") then {
						stop;
					}
					else
						if (string = "s") then {
							stop;
						}
						else
							if (string = "e") then {
								stop;
							}
							else
								if (string = "d") then {
									stop;
								}
								else{
									stop;
								}
								fi
							fi
						fi
					fi;
				}
				fi;
			} pool;
		}
	};

};