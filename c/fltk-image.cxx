// http://seriss.com/people/erco/fltk/#Fl_JPG_Image
#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Shared_Image.H>
#include <FL/Fl_JPEG_Image.H>
#include <FL/Fl_Box.H>
// COMPILE: fltk-config --use-images --compile fltk-image.cxx

int main() {
    // $  convert fltk-image.jpg -format "%w x %h" info:
    // 745 x 1040
    fl_register_images();                    // initialize image lib
    Fl_Window     win(745+20, 1040+20);      // make a window
    Fl_Box        box(10, 10, 745, 1040);    // widget that will contain image
    Fl_JPEG_Image jpg("fltk-image.jpg");     // load jpeg image into ram
    box.image(jpg);                          // attach jpg image to box
    win.show();
    return(Fl::run());
} 
