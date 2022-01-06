function match_o = getPreviousOutcomes(data)

prev_completed = [data.trials.previous_completed];
match_o = getOutcome(data);
match_o(~prev_completed)=nan;
