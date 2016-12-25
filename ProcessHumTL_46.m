function result = ProcessHumTL_46(imageIn, resultIn, nbrExpected, nbrResults, plottingOn, ellipse)
% 
filteredCircles = CannyHough(imageIn,nbrExpected,plottingOn);
edgeMap = DoubleThresholdConvexHull(imageIn,plottingOn);

[selected_1, conf_score_1] = EvalMatchLowHigh(edgeMap, filteredCircles, nbrExpected, plottingOn, ellipse)
% selected_2 = EvalTouchCH(edgeMap, filteredCircles,nbrExpected, plottingOn);
% selected_3 = EvalCoverCH(edgeMap, filteredCircles,nbrExpected,plottingOn);

% score_3 = CheckResult(selected_3, resultIn, nbrResults, plottingOn, 4)
score_1 = CheckResult(selected_1, conf_score_1, resultIn, nbrResults, plottingOn);
% score_2 = CheckResult(selected_2, result, nbrResults, plottingOn, 3)

result = score_1;