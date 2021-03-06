import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;
int [][] events;
int gridw = 5, gridh = 6;
int numberOfNotes = 10;
int[] context_array;
NoteEvent[] noteSequence;
ArrayList<NoteEvent> active_notes = new ArrayList<NoteEvent>();
//thumb: red
color thumb_soft = #FF6666;
color thumb_medium = #FF0000;
color thumb_hard = #990000;
//index: green
color index_soft = #99FF99;
color index_medium = #33FF33;
color index_hard = #009900;
//middle: yellow
color middle_soft = #FFFF99;
color middle_medium = #FFFF33;
color middle_hard = #CCCC00;
//ring: blue
color ring_soft = #99CCFF;
color ring_medium = #3333FF;
color ring_hard = #000099;
//pinky: orange
color pinki_soft = #FFCC99;
color pinki_medium = #FF8000;
color pinki_hard = #CC6600;

color[][] Colors = {  {thumb_soft, thumb_medium, thumb_hard},
                      {index_soft, index_medium, index_hard},
                      {middle_soft, middle_medium, middle_hard},
                      {ring_soft, ring_medium, ring_hard},
                      {pinki_soft, pinki_medium, pinki_hard}};
                      


public class NoteEvent{
      public int finger;
      public int pressure;
      public float duration;
      public float time;
      public int ticPassed;
      public boolean isActive;
      
      public NoteEvent(int finger, int pressure, float duration, float time) {
        this.finger = finger;
        this.pressure = pressure;
        this.duration = duration;
        this.time = time;
        this.isActive = false;
        this.ticPassed = 0;
      }

      public NoteEvent() {
        this.finger = 1;
        this.pressure = 0;
        this.duration = 1;
        //this.time = time;
      }
}



void setup() {
  size(320,240);
  frameRate(60);
  oscP5 = new OscP5(this,12345);
  myRemoteLocation = new NetAddress("127.0.0.1",1234);
  events = new int[gridw][gridh];
  context_array = new int[5];
  buildSong(10);
  strokeWeight(3);
  String[] fingers = loadStrings("song/fingers.txt");
  String[] pressures = loadStrings("song/pressures.txt");
  String[] time = loadStrings("song/tempos.txt");
  String[] duration = loadStrings("song/durations.txt");
  NoteEvent note;  
  for (int i = 0 ; i < fingers.length; i++) {
    note = new NoteEvent(Integer.parseInt(fingers[i]), Integer.parseInt(pressures[i]), float(duration[i]), float(time[i]));
    active_notes.add(note);
}
}

void buildSong(int numberOfNotes) {
  noteSequence = new NoteEvent[numberOfNotes];
  for(int note = 0; note < numberOfNotes; note++) {
    noteSequence[note] = new NoteEvent();
  }
}
  //print(noteSequence[0].finger);

void sendMsgInt(String addr, int v) {
  OscMessage myMessage = new OscMessage(addr);
  myMessage.add(v); 
  oscP5.send(myMessage, myRemoteLocation); 
}

int ih_old = -1;
int t = 0;

void draw() {
  int dw = int(width/float(gridw));
  int dh = int(height/float(gridh));
  int ih = (frameCount%height) / dh;
  int reference_line = height-dh;
  boolean tic = ih_old != ih;
  ih_old = ih;
  stroke(255);
  for(int i=0;i<gridw;i++) {
    for(int j=0;j<gridh;j++) {
      fill(0);
      rect(i*dw,j*dh,dw,dh); 
    }
  }
  stroke(color(0, 250, 59));
  line(0,reference_line, width, reference_line); //reference line
  for (int i = 0; i < active_notes.size(); i++) { 
    NoteEvent noteEv = active_notes.get(i);
    int finger = noteEv.finger;
    int pressure = noteEv.pressure;
    float time = noteEv.time;
    float y_pos = frameCount - time * dh;
    //noteEv.isActive = true;

    if (noteEv.isActive) {
      fill(Colors[finger][pressure]);
      rect(finger*dw, y_pos-noteEv.duration % height, dw, dh*noteEv.duration);
    }
    if (tic) {
      noteEv.ticPassed++;
    }
    
    if (noteEv.ticPassed > gridh + noteEv.time) {
      noteEv.isActive = false;
      //active_notes.remove(i);
    }
    else {
      if(y_pos+noteEv.duration*dh>0){
              noteEv.isActive = true;        
      }
    }
  }
  delay(30);
}


void mousePressed() {
  int gi = int(mouseX/float(width) * gridw);
  int gj = int(mouseY/float(height) * gridh);
  if(events[gi][gj] > 0) events[gi][gj] = 0;
  else events[gi][gj] = 1; 
}