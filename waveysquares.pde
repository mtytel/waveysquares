WaveGrid grid;

int grid_x = 0;
int grid_y = 0;
int cell_width = 4;
int cell_height = 4;

void setup() {
  size(800, 450);

  int rows = 111;
  int cols = 198;
  grid = new WaveGrid(rows, cols);
  grid.setDamping(0.001);
  noStroke();
}

void keyPressed() {
  grid.bloop(); 
}

void mouseMoved() {
  int mouse_row = (mouseY - grid_y) / cell_height;
  int mouse_col = (mouseX - grid_x) / cell_width;
  grid.impulseCell(mouse_row, mouse_col, 0.1);
}

void draw() {

  background(0);
  grid.update();
  
  for (int r = 1; r <= grid.rows; r++) {
    for (int c = 1; c <= grid.cols; c++) {
      float wid = cell_width * grid.positions[r][c];
      float hei = cell_height * grid.positions[r][c];
      float col = 255 * grid.positions[r][c];
      if (col >= 0) {
        fill(col);
        rect(grid_x + c * cell_width - wid / 2, grid_y + r * cell_height - hei / 2, cell_width, cell_height);
      }
    }
  }
}

class WaveGrid {
  int rows, cols;
  float[][] positions;
  float[][] velocities;
  
  float damping; // Reduces overall energy.
  float wave_force; // Kind of controls wave speed.
  
  WaveGrid(int r, int c) {
    rows = r;
    cols = c;
    positions = new float[rows + 2][cols + 2]; // +2 for borders
    velocities = new float[rows + 2][cols + 2]; // +2 for borders
    
    damping = 0.0;
    wave_force = 0.1;
  }
  
  void setDamping(float d) {
    damping = d;
  }
  
  void impulseCell(int r, int c, float impulse) {
    if (r > 0 && r <= rows && c > 0 && c <= cols)
      velocities[r][c] += impulse;
  }
  
  void update() {
    // Update velocities.
    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= cols; c++) {
        float desired_position = (positions[r - 1][c] + positions[r + 1][c] + positions[r][c - 1] + positions[r][c + 1]) / 4.0;
        float impulse = (desired_position - positions[r][c]) * wave_force;
        velocities[r][c] += impulse;
        velocities[r][c] *= (1 - damping);
      }
    }
    
    // Update positions.
    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= cols; c++) {
        positions[r][c] += velocities[r][c];
      }
    }
  }
  
  void bloop() {
    float edge_value = 0.0;
    if (positions[0][0] == 0)
      edge_value = 0.5;
      
    for (int r = 0; r < rows; r++) {
      positions[r][0] = edge_value; 
      positions[r][cols + 1] = edge_value; 
    }
    for (int c = 0; c < cols; c++) {
      positions[0][c] = edge_value; 
      positions[rows + 1][c] = edge_value; 
    }
  }
}


