# Driver Architecture

The actual parsing of input is handled by a so called "driver" represented as
the class `LL::Driver`. This class is written in either C or Java depending on
the Ruby platform that's being used. The rationale for this is simple:
performance. While Ruby is a great language it's sadly not fast enough to handle
parsing of large inputs in a way that doesn't either require lots of memory,
time or both.

Both the C and Java drivers try to use native data structures as much as
possible instead of using Ruby structures. For example, their internal parsing
stacks are native stacks. In case of Java this is an ArrayDeque, in case of C
this is a vector created using the [kvec][kvec] library as C doesn't have a
native vector structure.

The driver operates by iterating over every token supplied by the `each_token`
method (this method must be defined by a parser itself). For every input token a
callback function in C/Java is executed that determines what to parse and how to
parse it.

The parsing process largely operates on integers, only using Ruby objects where
absolutely required. For example, all steps of a rule's branch are represented
as integers. Lookup tables are also simply arrays of integers with terminals
being mapped directly to the indexes of these arrays. See ruby-ll's own parser
for examples. Note that the integers for the `rules` Array are in reverse order,
so everything that comes first is processed last.

For more information on the internals its best to refer to the C driver code
located in `ext/c/driver.c`. The Java code is largely based on this code safe
for some code comments here and there.

[kvec]: https://github.com/attractivechaos/klib/blob/master/kvec.h
