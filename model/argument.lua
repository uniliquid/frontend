Argument = mondelefant.new_class()
Argument.table = 'argument'

Argument:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Argument:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'author_id',
  that_key      = 'id',
  ref           = 'author',
}

Argument:add_reference{
  mode          = '1m',
  to            = "Rating",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'ratings',
  back_ref      = 'issue',
  default_order = '"id"'
}

model.has_rendered_content(Argument, RenderedArgument)
