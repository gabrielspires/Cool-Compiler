(* Sua implementação deverá estar neste arquivo.  *)

class Stack {
	top () : String { (*Inicializa a pilha com uma flag*)
		{
			"%";
		}
	};

	stack () : Stack { (*Retorna o corpo da pilha*)
		{
			self;
		}
	};

	push (new_item : String) : Stack { (*Insere novo elemento em self*)
		(new Push).insert(new_item, self) 
	};

	pop () : Stack{ (*Remove elemento e retorna apenas o corpo da pilha (sem o topo)*)
		(new Pop).remove(self.top(), self.stack()) 
	};
};

class Push inherits Stack {
	new_element : String;
	stack_content : Stack;

	top() : String { (*Receberá o novo valor para o topo da pilha*)
		new_element
	};

	stack() : Stack { (*Retorna o corpo da pilha*)
		stack_content
	};

	insert(new_item : String, rest_of_stack : Stack) : Stack {
		{ (*Altera o topo da pilha e atribui a pilha antiga ao corpo desta nova pilha*)
			new_element <- new_item;
			stack_content <- rest_of_stack;
			self; (* return *)
		}
	};
};

class Pop inherits Stack {
	new_top_element : String;
	stack_content : Stack;

	top() : String { (*Receberá o valor do topo do corpo da pilha*)
		new_top_element
	};

	stack() : Stack { (*Retorna o corpo da pilha*)
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

class Main inherits IO {
	stop : Bool <- false;
	program_stack : Stack;
	input_string : String;
	item : String;
	x : String;
	y : String;
	z : Int;
	x_to_int : Int;
	y_to_int : Int;

	displayStack(stack : Stack) : Object {
		if (stack.top() = "%") then
			out_string("")
		else {
			out_string(stack.top().concat("\n"));
			displayStack(stack.stack());
		} fi
	};

	isOperation(item : String) : Bool {
		if (item = "s") then
			true
		else
			if (item = "+") then
				true
			else
				false
			fi
		fi
	};

	main() : Object {
		{
			program_stack <- (new Stack).push("%");
			out_string(">");
			input_string <- in_string();
			while (not stop) Loop {
				if (input_string = "x")
					then stop <- true
				else {
					if (input_string = "e") then {
						item <- program_stack.top();
						(*out_string(item);*)
						if  (isOperation(item)) then {
							if (item = "s") then {
								(*Swaps the last two items*)
								(*out_string("deu S\n");*)
								program_stack <- program_stack.pop();
								x <- program_stack.top();
								program_stack <- program_stack.pop();
								y <- program_stack.top();
								program_stack <- program_stack.pop();
								program_stack <- program_stack.push(x);
								program_stack <- program_stack.push(y);
							} else {
								(*Adds the last two items*)
								program_stack <- program_stack.pop();
								x_to_int <- (new A2I).a2i(program_stack.top());
								program_stack <- program_stack.pop();
								y_to_int <- (new A2I).a2i(program_stack.top());
								program_stack <- program_stack.pop();

								z <- x_to_int + y_to_int;
								program_stack <- program_stack.push((new A2I).i2a(z));
							} fi;
						} else {
							item <- program_stack.top();
						} fi;
					}
					else {
						if (input_string = "d") then {
							displayStack(program_stack);
						} else {
							(*out_string("push");*)
							program_stack <- program_stack.push(input_string);
						} fi;
					} fi;
					out_string(">");
					input_string <- in_string();
				} fi;
			} pool;
		}
	};
};