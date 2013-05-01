function getPixels(pixels)
{
    if (pixels == null)
        return 0;
    return parseInt(pixels.replace("px", ""));
}

function disableGlobalTextSelection()
{
    document.body.classList.add("disable-selection");
}

function enableGlobalTextSelection()
{
    document.body.classList.remove("disable-selection");
}

function isPointInsideNode(px, py, node)
{
    var element = node.container.containerElement;
    var x = element.offsetLeft;
    var y = element.offsetTop;
    var width = element.clientWidth;
    var height = element.clientHeight;

    return (px >= x && px <= x + width && py >= y && py <= y + height);
}

function Rectangle()
{
//    num x;
//    num y;
//    num width;
//    num height;
}

function getNextId(prefix)
{
    return prefix + getNextId.counter++;
}
getNextId.counter = 0;

function removeNode(node)
{
    if (node.parentNode == null)
        return false;
    node.parentNode.removeChild(node);
    return true;
}

function Point(x, y)
{
    this.x = x;
    this.y = y;
}
