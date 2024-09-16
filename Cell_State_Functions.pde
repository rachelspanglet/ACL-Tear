void setInitialCells() {  //set cells for first frame
  for (int i = 0; i < gridSize; i++) {
    for(int j = 0; j < gridSize; j++) {
      int middle = ceil(gridSize/2);  //central row of the grid
      
      //set one column on each side to be empty joint space
      if (i == 0 || i == gridSize - 1) {
        cellStates[i][j] = color(0);
        tissue[i][j] = false;
      }
      
      //set cells representing tear
      else if (j == middle - 1 || j == middle || j == middle + 1) {
        if (fullTear) {  //if full tear, set the whole centre row and the row above and below to be the tear
          cellStates[i][j] = color(0);
          tissue[i][j] = false;
        }
        
        else if (i < middle) {  //if partial tear and on the left side, set centre row to tear
          cellStates[i][j] = color(0);
          tissue[i][j] = false;
        }
        
        else {
          cellStates[i][j] = color(209, 197, 142);      //otherwise, set cell to be healthy tissue
          tissue[i][j] = true;
        }
      }
      
      //generate random jagged edge of tear
      else if (j == middle + 2 || j == middle - 2) {
        float jagged = random(0, 1);  //cells above tear have a 1/2 chance of being part of the jagged tear line
        if (jagged < 0.5 && (fullTear || i < middle)) {
          cellStates[i][j] = color(0);
          tissue[i][j] = false;
        }
        
        else {  //otherwise set to healthy tissue
          cellStates[i][j] = color(209, 197, 142);   
          tissue[i][j] = true; 
        }
      }
      
      else {  //set everything left to healthy tissue
        cellStates[i][j] = color(209, 197, 142);   
        tissue[i][j] = true;
      }  
    }
  }
}

void updateCells() {  //update cells every frame
  //rate at which RGB values change as inflammation decreases
  int deflatingRed = ceil((maxInflammation - 209.0)/daysToNormal);
  int deflatingGreen = ceil(197.0/daysToNormal);
  int deflatingBlue = ceil(142.0/daysToNormal);
  
  //rate at which RGB values change as inflammation increases
  int inflatingRed = ceil((maxInflammation - 209.0)/daysToMaxInflam);
  int inflatingGreen = ceil(197.0/daysToMaxInflam);
  int inflatingBlue = ceil(142.0/daysToMaxInflam);

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      //RGB values for next generation of cell
      float newRed;
      float newGreen;
      float newBlue;
      
      if (daysSinceIncident < daysToNormal + daysToMaxInflam && daysSinceIncident > daysToMaxInflam && tissue[i][j]) {  //start decreasing inflammation

        if (abs(red(cellStates[i][j]) - 209) > abs(deflatingRed))   //decrease red value if not achieved healthy value of 209 yet
          newRed = red(cellStates[i][j]) - deflatingRed;
        else  //otherwise set to 209
          newRed = 209;
        if (abs(green(cellStates[i][j]) - 197) > abs(deflatingGreen))  //increase green value if not yet achieved healthy value of 197
          newGreen = green(cellStates[i][j]) + deflatingGreen;
        else  //otherwise set to 197
          newGreen = 197;
        if (abs(blue(cellStates[i][j]) - 142) > abs(deflatingBlue))  //increase blue value if not yet achieved healthy value of 142
          newBlue = blue(cellStates[i][j]) + deflatingBlue;
        else  //otherwise set to 142
          newBlue = 142;
        
        cellsNext[i][j] = color(newRed, newGreen, newBlue);  //update cellsNext with new RGB values
        
        if (surgery) {  //if surgery has occurred...
          float probabilityOfInfect = probabilityOfInfect(i, j);  //there is a chance of infection for a tissue cell.
          
          float infect = random(0, 100);
          
          if (infect < probabilityOfInfect) {
            cellsNext[i][j] = color(0, 255, 0);
          }
        }
      }
      
      else if (daysSinceIncident >= daysToNormal && tissue[i][j]) {  //set all tissue cells to healthy if it's been the number of days required to return to normal
        cellsNext[i][j] = color(209, 197, 142);
      } 
      
      else if (tissue[i][j] && daysSinceIncident <= daysToMaxInflam) {  //first few days after incident, increase inflammation of tissue cells
        //inflatingRed = ceil((maxInflammation - 209.0)/daysToNormal);
        if (red(cellStates[i][j]) < maxInflammation - distanceFromSurgery(i, j)) //increase red if not achieved max (surroundedByInjury takes distance into account)
          newRed = red(cellStates[i][j]) + inflatingRed;
        else  //otherwise set to max
          newRed = maxInflammation - distanceFromSurgery(i, j);       
        if (green(cellStates[i][j]) > 0)  //decrease green all the way to minimum
          newGreen = green(cellStates[i][j]) - inflatingGreen/distanceFromSurgery(i, j);
        else  //otherwise set green to exactly 0
          newGreen = 0;
        if (blue(cellStates[i][j]) > 0)  //decrease blue to minimum
          newBlue = blue(cellStates[i][j]) - inflatingBlue/distanceFromSurgery(i, j);
        else  //otherwise set blue exactly to 0
          newBlue = 0;
          
        cellsNext[i][j] = color(newRed, newGreen, newBlue);  //set new colour in cellsNext
      }
      
      else if (surgery) {  //otherwise, set tear space cells to graft colour
        if (i != 0 && i != gridSize - 1) {
          cellsNext[i][j] = color(0, 0, 255);
        }
      }
    }
  }
  
  //overwrite cellStates (no need to update tissue since it stays the same)
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      cellStates[i][j] = cellsNext[i][j];
    }
  }
}

//determine probability of infection for a tissue cell with coordinates (x, y)
float probabilityOfInfect(int x, int y) {
  int numInfection = 0;
  
  //check if surrounding cells are infected
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      try {
        if (green(cellStates[x + i][y + j]) > 197 && (i != 0 || j != 0)) {  //if surrounding cell has been turned more green than healthy state, is infected
          numInfection++;
        }
      }
      
      catch(IndexOutOfBoundsException e) {
      }
    }
  }
  
  float probOfInfect;
  
  if (daysSinceIncident < 60)  //if less than 2 months since incident, cells can become infected on their own (+1 to numInfection)
    probOfInfect = (1 - immuneSensitivity)*(numInfection + 1);
  else  //otherwise they can only be infected if surrounding cells are already infected (no +1 to numInfection)
    probOfInfect = (1 - immuneSensitivity)*(numInfection);
  
  return probOfInfect;
}

//determine distance of tissue cell from injury or surgery
float distanceFromSurgery(int x, int y) {
  int middle = ceil(gridSize/2);  //middle row
  float dist;
  
  if (fullTear) {  //if full tear...
    dist = abs(middle - y);     //distance from issue described by distance from centre
    
    //account for jagged edge as part of tear
    if (y > middle && !tissue[x][middle + 2])
      dist -= 1;
    else if (y < middle && !tissue[x][middle - 2])
      dist -= 1;
  }
  
  else {  //partial tear
    if (x < middle) {  //if x is on the left half of the grid...
      dist = abs(middle - y);  //distance from injury is distance from middle
      
      //account for jagged edge
      if (y > middle && !tissue[x][middle + 2])
        dist -= 1;    
      else if (y < middle && !tissue[x][middle - 1])
        dist -= 1;
    }
    
    else {  //x is on the right half of the grid
      dist = pow(pow(middle - x, 2) + pow(middle - y, 2), 0.5);  //use pythagorean theorem for distance
    }
  }
  

  return dist/2 - 0.5;
}
