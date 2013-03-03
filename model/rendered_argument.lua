RenderedArgument = mondelefant.new_class()
RenderedArgument.table = 'rendered_argument'
RenderedArgument.primary_key = { "argument_id", "format" }

RenderedArgument:add_reference{
  mode          = 'm1',
  to            = "Argument",
  this_key      = 'argument_id',
  that_key      = 'id',
  ref           = 'argument',
}
