function [val, Sn] = popfield(S, field)
  val = getfield(S, field);
  Sn  = rmfield(S, field);
end
