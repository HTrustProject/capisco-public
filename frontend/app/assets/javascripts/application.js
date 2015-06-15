// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require turbolinks
//= require_tree .

// Returns an array of only the unique values in the input array
var arrayUnique = function (array) {
    return array.reduce(function (p, c) {
        if (p.indexOf(c) < 0) p.push(c);
        return p;
    }, []);
};

function createCookie(name, value, days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        var expires = "; expires=" + date.toGMTString();
    }
    else var expires = "";
    document.cookie = name + "=" + value + expires + "; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}

function readCookieAsBoolean(name) {

    var cookieVal = readCookie(name);
    if (cookieVal === "true") {
        return true;
    } else { // can be null or string

        return false;
    }

}


// Given an array containing elements [D, E, A, C, B], this function will return an array with all combinations of the elements,
// sorted alphabetically and then by descending array length:
//
// [["A", "B", "C", "D", "E"], ["A", "B", "C", "D"], ["A", "B", "C", "E"], ["A", "B", "D", "E"], ["A", "C", "D", "E"], ["B", "C", "D", "E"], 
// ["A", "B", "C"], ["A", "B", "D"], ["A", "B", "E"], ["A", "C", "D"], ["A", "C", "E"], ["A", "D", "E"], ["B", "C", "D"], ["B", "C", "E"], ["B", "D", "E"], ["C", "D", "E"], 
// ["A", "B"], ["A", "C"], ["A", "D"], ["A", "E"], ["B", "C"], ["B", "D"], ["B", "E"], ["C", "D"], ["C", "E"], ["D", "E"], 
// ["A"], ["B"], ["C"], ["D"], ["E"]]
//
// Note that variations in element order are considered duplicates and not generated.
//
// http://codereview.stackexchange.com/questions/7001/better-way-to-generate-all-combinations
// Then sort with http://stackoverflow.com/questions/10630766/sort-an-array-based-on-the-length-of-each-element
// (English language description: http://stackoverflow.com/questions/127704/algorithm-to-return-all-combinations-of-k-elements-from-n/8171776#8171776 )
function getCombinations(arr) {
    var fn = function (active, rest, a) {
        if (active.length <= 0 && rest.length <= 0)
            return;
        if (rest.length <= 0) {
            a.push(active);
        } else {
            var newArray = active.slice(); // copy
            newArray.push(rest[0]);
            fn(newArray, rest.slice(1), a);
            fn(active, rest.slice(1), a);
        }
        return a;
    };
    //return fn([], arr, []);

    // Make it alphabetical. Get the combinations. The combinations produced will then be alphabetical. Then sort combinations by array length
    arr.sort();
    var combinations_array = fn([], arr, []);
    combinations_array.sort(function (a, b) {
        return b.length - a.length;
    });
    console.log(combinations_array);
    return combinations_array;
}

function getSentences(text) {
    var sentences = text.split(/[.|!|?]\s/gi);
    return sentences;
}

function getWords(text) {
    var words = text.split(" ");
    return words;
};

function getLines(text, width) {
    var words = getWords(text);
    var lines = [];
    var line = "";
    for (var index in words) {
        word = words[index];
        if (line.length + word.length > width) {
            lines.push(line);
            line = word;
        } else {
            line += " ";
            line += word;
        }
    }
    lines.push(line);
    return lines;
};
