function getnodeinfo()
    keys = {"majorVer  ", "minorVer  ", "devVer    ", "chipid    ", "flashid   ", "flashsize ", "flashmode ", "flashspeed"}
    vals = {node.info()}
    info = {}
    for k,v in pairs(vals) do
        info[keys[k]] = v
    end
    return info
end


for k,v in pairs(getnodeinfo()) do
    print(k .. "\t" .. v)
end
