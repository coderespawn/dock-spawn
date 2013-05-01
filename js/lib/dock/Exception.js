dockspawn.Exception = function(message)
{
    this.message = message;
}

dockspawn.Exception.prototype.toString = function()
{
    return this.message;
};
