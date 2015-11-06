function [promptWithPID] = logPrompt(fname)
  promptWithPID = sprintf('PID:%d - %s', feature('getpid'), fname);
