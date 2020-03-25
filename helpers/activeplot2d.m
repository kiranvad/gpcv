function activeplot2d(problem, train_ind, observed_labels)

  % find bounding box for points
  x_min = min(problem.points(:, 1));
  y_min = min(problem.points(:, 2));
  x_max = max(problem.points(:, 1));
  y_max = max(problem.points(:, 2));

  % clear figure
  clf;
  % Trained Points 
    plot(problem.points(train_ind(1:problem.num_initial), 1), ...
       problem.points(train_ind(1:problem.num_initial), 2), 'go','LineWidth',2.0,'MarkerEdgeColor',[0 0.5 0]);
  % plot observed points
  legendmat = {'Trained Points'};
  hold('on');
  grid on;
  % interesting points in red
  ind = (observed_labels == 1);
  h=plot(problem.points(train_ind(ind), 1), ...
       problem.points(train_ind(ind), 2), 'rx','LineWidth',2.0);
  if ~isempty(h)
      legendmat = cat(2,legendmat,{'queried positives'});
  end
  clearvars h
  % uninteresting points in black
  ind = (observed_labels ~= 1);
  h=plot(problem.points(train_ind(ind), 1), ...
       problem.points(train_ind(ind), 2), 'kx','LineWidth',2.0);
   if ~isempty(h)
       legendmat = cat(2,legendmat,{'queried negatives'});
   end
   clearvars h
  % Selected batch of points
   latest_batch = train_ind(end-problem.batch_size+1:end);
  h=plot(problem.points(latest_batch, 1), ...
       problem.points(latest_batch, 2), 'bo', 'MarkerEdgeColor','c','LineWidth',2.0);
   if ~isempty(h)
       legendmat = cat(2,legendmat,{'current batch'});
   end
   clearvars h
  % make plot square
  axis('equal');
  axis('square');

  % set bounding box of plot
  axis([x_min, x_max, y_min, y_max]);
  legend(legendmat, 'Location', 'eastoutside','interpreter','latex','FontSize',15);
  drawnow;
  % wait for keyboard input, you might want to eventually comment this
%   disp('press any key to continue...');
%   pause;

end
