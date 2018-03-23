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

public class NoteEvent{
      public int finger;
      public int pressure;
      public float duration;
      public int counter;
      public float time;
      public int ticPassed;
      public boolean isActive;
      
      public NoteEvent(int finger, int pressure, float duration, int counter, float time) {
        this.finger = finger;
        this.pressure = pressure;
        this.duration = duration;
        this.counter = counter;
        this.time = time;
        this.isActive = true;
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
  frameRate(30);
  oscP5 = new OscP5(this,12345);
  myRemoteLocation = new NetAddress("127.0.0.1",1234);
  events = new int[gridw][gridh];
  context_array = new int[5];
  buildSong(10);
  strokeWeight(3);
}

void buildSong(int numberOfNotes) {
  noteSequence = new NoteEvent[numberOfNotes];
  for(int note = 0; note < numberOfNotes; note++) {
    noteSequence[note] = new NoteEvent();
  }
  //print(noteSequence[0].finger);
}

void sendMsgInt(String addr, int v) {
  OscMessage myMessage = new OscMessage(addr);
  myMessage.add(v); 
  oscP5.send(myMessage, myRemoteLocation); 
}

int ih_old = -1;
int t = 0;

void draw() {
  int y = 0;
  int dw = int(width/float(gridw));
  int dh = int(height/float(gridh));
  int ih = (frameCount%height) / dh;
  int reference_line = height-dh;
  boolean tic = ih_old != ih;
  NoteEvent note;
  if(tic) {
    //for(int j = 0;j<gridw;j++) {
    //  if(events[j][ih] > 0) sendMsgInt("/play",j+1); // si algun es troba al grid iw mira per tots els heighs i si algun > 0 envia missatge play
    //  else {
    //    if(events[j][(ih-1+gridh)%gridh] > 0) sendMsgInt("/stop",j+1); //si algun es troba al grid iw-1 mira per tots els heighs i si algun > 0 envia missatge stop 
    //  }
    //print
        
    //t++;
    //}
    fill(thumb_hard);
    for (int i=0; i < 5; i++) {
      context_array[i] = int(random(0,1.9));
      if(context_array[i] == 1) {
        float start_delay = random(0,0.9);
        note = new NoteEvent(i, 1, 0.5, 1, ih+start_delay);
        active_notes.add(note);
        //print(active_notes);
      }
    }
  } 
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
  //for (NoteEvent noteEv : active_notes) {
    NoteEvent noteEv = active_notes.get(i);
    int finger = noteEv.finger;
    float time = noteEv.time;
    float y_pos = frameCount - time * dh;
    if (noteEv.isActive) {
      fill(thumb_hard);
      rect(finger*dw, y_pos % height, dw, dh*noteEv.duration);
    }
    if (tic) {
      noteEv.ticPassed++;
    }

    if (noteEv.ticPassed > gridh) {
      noteEv.isActive = false;
      //active_notes.remove(i);
    }
  }
  delay(20);
}

void mousePressed() {
  int gi = int(mouseX/float(width) * gridw);
  int gj = int(mouseY/float(height) * gridh);
  if(events[gi][gj] > 0) events[gi][gj] = 0;
  else events[gi][gj] = 1; 
}