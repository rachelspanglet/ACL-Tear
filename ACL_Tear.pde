boolean fullTear = true;         //either is full or partial tear
boolean surgery = false;         //whether animation starts before or after surgery (can also change it during the animation with mouse click)         
float immuneSensitivity = 0.9;   //could go from 0-1.00, but suggested range from 0.8 to 1.00
int gridSize = 30;
float cellSize = 600/gridSize;
color[][] cellStates = new color[gridSize][gridSize];  //colours of cells
color[][] cellsNext = new color[gridSize][gridSize];   //upcoming colours of cells
boolean[][] tissue = new boolean[gridSize][gridSize];  //boolean 2D array for whether a cell is tissue or not to checl if it can be inflamed or infectef
int daysSinceIncident = 0;                             //days since an incident (either injury or surgery)
int maxInflammation = round(255*immuneSensitivity);    //maximum possible red value for inflammation
int daysToNormal = round(80*immuneSensitivity);        //recovery period for an incident
int daysToMaxInflam = int(random(2, 6));               //random days it takes to reach maximum inflammation

void setup() {
  size(600, 600); 
  frameRate(11);  //each frame represents a day
  
  setInitialCells();
  if (fullTear) {
    daysToNormal *= 1.3; //if full tear, increase recovery period
  }
}

void draw() {  
  //draw cells
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      fill(cellStates[i][j]);
      
      float x = i * cellSize;
      float y = j * cellSize;
      rect(x, y, cellSize, cellSize);
    }
  }
  
  daysSinceIncident++;  //increment days since incident (1 frame = 1 day)
  updateCells();        //update cell states
}
