require('UIColor');

defineClass('ViewController', {
    buttonClicked: function() {
        self.view().setBackgroundColor(UIColor.greenColor());
    }
});

require('ViewController');

// function b(ctn, succ){
//     if (succ) console.log(ctn);
// }

let b = block("NSString *, BOOL", function(ctn, succ) { if (succ) console.log(ctn) });

defineClass('ViewController', {
    request: function(b1)
    {
        console.log(typeof b1);
        console.log("???");
    },
})

ViewController.new().request(b);

require('ViewController').request(b);

var blk = require('ViewController').genBlock();

console.log(typeof blk);
console.log(typeof b);

blk({v: "0.0.1"});
// b("I'm content", YES);
