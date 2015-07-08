defmodule Eetoul.Commands.AddTo do
  use Eetoul.CommandDSL

  command do
    release :release
    reference :branch
    flag :squash
    flag :merge
    string :message
  end

  validate "Arguments --squash and --merge cannot both be specified." do
    !(args[:squash] && args[:merge])
  end
  
  validate "Argument --message is requires if --squash or --merge are specified." do
    !((args[:squash] || args[:merge]) && !args[:message])
  end
end
