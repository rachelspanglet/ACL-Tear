void mousePressed() {
  if (daysSinceIncident >= daysToNormal) {  //mouse click indicates surgery, but only after subject is back to normal
    surgery = true;
    daysSinceIncident = 0;  //surgery counts as incident causing inflammation, so set to 0
    daysToNormal = 1000;  //set to very high number since days to normal is dependent on whether infection occurs
  }
  
  else if (surgery) {  //mouse click treats post-surgery infection with antibiotics
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (green(cellStates[i][j]) > 197) {  //if cell is infected...
          
          float cureOrNot = random(0, 1);
          
          if (cureOrNot < 0.95) {  //95% chance of curing an infected cell
            cellStates[i][j] = color(209, 197, 142);
          }
        }
      }
    }
  }
}
