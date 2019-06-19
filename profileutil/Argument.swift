// https://gist.github.com/perhapsmaybeharry/7fcd8ad592e9b47ce01c49e8ee8b9f01

import Foundation

extension String {
	/// Checks if the string is prefixed with one of the prefixes specified in the array.
	func prefixedWithEither(_ of: [String]) -> Bool {
		return of.filter({ self.hasPrefix($0) }).count > 0
	}
}

extension CommandLine {
	///	Command line argument parsing function that helps Swift
	///	  applications designed for the command line parse and
	///	  access arguments easier and in less code by extending
	///	  the CommandLine enum.
	///
	///	The function recognises arguments prefixed with
	///	  `"-"`, `"--"` and `"+"` by default. Alternatively, you can
	///	  supply custom prefixes in the argumentPrefixes array.
	///
	///	Calling this function returns the arguments and their values
	///	  in a dictionary, with the name of the argument as the key.
	///
	///	For example, consider the argument array below:
	///
	///	    ["-a", "example", "--second", "5", "+t"]
	///
	///	Passing this array to this function returns the following
	///	  dictionary:
	///
	///	    ["-a": "example", "--second": "5", "+t": ""]
	///
	///	From there, your program can access its arguments through
	///	  the dictionary by using the argument name:
	///
	///	    let value = parsed["-a"]  // `value` is now "example"
	///
	///	- Parameter argumentPrefixes: An array that contains the
	///		string values for argument name prefixes. For example,
	///		with the array:
	///
	///       ["-", "--", "+"]
	///
	///		the parse function will recognise all arguments beginning
	///		with `"-"`, `"--"` and `"+"` as argument names.
	///
	/// - Returns: A String-based dictionary that contains argument names as keys
	///		and provided argument values as values.
	///
	///       [(argument name): (argument value)]
	static func parse(_ argumentPrefixes: [String] = ["-", "--", "+"]) -> [String: String] {
		
		// Define the parsed dictionary.
		var parsed = [String: String]()
		
		// Iterate through each element of the arguments array.
		for pos in 0..<self.arguments.count {
			
			// If the argument is prefixed with either argument prefix...
			if self.arguments[pos].prefixedWithEither(argumentPrefixes) {
				
				// ...and the array contains at least one more non-prefixed element for the value...
				if (pos+1) < self.arguments.count && !self.arguments[pos+1].prefixedWithEither(argumentPrefixes) {
					
					// ...set the argument to the value in the dictionary.
					parsed[self.arguments[pos]] = self.arguments[pos+1]
				} else {
					
					// ...or if the argument is independent and does not have any values...
					// ...set the argument to an empty string value in the dictionary.
					parsed[self.arguments[pos]] = String()
				}
			}
		}
		
		// Return the parsed dictionary.
		return parsed
	}
}
