# Adapted from the standard YASim fuel handling script.
# Will work with any plane that has 3 engines and 3 fuel tanks.

var UPDATE_PERIOD = 0.3;

var update = func {
  if (fuel_freeze)
    return;
  
  var fuel_level = 0;
  
  var consumed_fuel_0 = getprop("engines/engine[0]/fuel-consumed-lbs");
  var consumed_fuel_1 = getprop("engines/engine[1]/fuel-consumed-lbs");
  var consumed_fuel_2 = getprop("engines/engine[2]/fuel-consumed-lbs");
  setprop("engines/engine[0]/fuel-consumed-lbs", 0);
  setprop("engines/engine[1]/fuel-consumed-lbs", 0);
  setprop("engines/engine[2]/fuel-consumed-lbs", 0);

  var selected_tanks = [];                                  #fill an array with selected tanks
  foreach (var t; tanks) {
    var cap = t.getNode("capacity-gal_us",0);
    var selected = t.getNode("selected");
    if ((cap!=nil) and (cap.getValue() > 0.01) and (t.getNode("level-lbs") != nil) and
      (selected != nil) and selected.getBoolValue())
      append(selected_tanks, t);
  }

  # Subtract fuel from tanks, set auxiliary properties.  Set out-of-fuel
  # when any one tank is dry.
  var out_of_fuel = 0;
  if (size(selected_tanks) == 0) {                              #if the array is of size 0,
    setprop("engines/engine[0]/out-of-fuel", "true");                     #we are setting all engines to out-of-fuel
    setprop("engines/engine[1]/out-of-fuel", "true");
    setprop("engines/engine[2]/out-of-fuel", "true");
  } else {

    if (getprop("consumables/fuel/tank[0]/selected"))
    {
      setprop("consumables/fuel/tank[0]/level-lbs", getprop("consumables/fuel/tank[0]/level-lbs") - consumed_fuel_0);
    }
    if (getprop("consumables/fuel/tank[0]/empty") == nil)
    {
      setprop("consumables/fuel/tank[0]/empty", lbs.getValue() <= 0);
    }
    if (getprop("consumables/fuel/tank[0]/empty"))
    {
      setprop("engines/engine[0]/out-of-fuel", "true");
    } else {
      setprop("engines/engine[0]/out-of-fuel", "false");
    }
    if (!getprop("consumables/fuel/tank[0]/selected"))
    {
      setprop("engines/engine[0]/out-of-fuel", "true");
    }
      
    if (getprop("consumables/fuel/tank[1]/selected"))
    {
      setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") - consumed_fuel_1);
    }
    if (getprop("consumables/fuel/tank[1]/empty") == nil)
    {
      setprop("consumables/fuel/tank[1]/empty", lbs.getValue() <= 0);
    }
    if (getprop("consumables/fuel/tank[1]/empty"))
    {
      setprop("engines/engine[1]/out-of-fuel", "true");
    } else {
      setprop("engines/engine[1]/out-of-fuel", "false");
    }
    if (!getprop("consumables/fuel/tank[1]/selected"))
    {
      setprop("engines/engine[1]/out-of-fuel", "true");
    }
      
    if (getprop("consumables/fuel/tank[2]/selected"))
    {
      setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") - consumed_fuel_2);
    }
    if (getprop("consumables/fuel/tank[2]/empty") == nil)
    {
      setprop("consumables/fuel/tank[2]/empty", lbs.getValue() <= 0);
    }
    if (getprop("consumables/fuel/tank[2]/empty"))
    {
      setprop("engines/engine[2]/out-of-fuel", "true");
    } else {
      setprop("engines/engine[2]/out-of-fuel", "false");
    }
    if (!getprop("consumables/fuel/tank[2]/selected"))
    {
      setprop("engines/engine[2]/out-of-fuel", "true");
    }
  }
}

var loop = func {
  call(update, [] );
  settimer(loop, UPDATE_PERIOD, 1);
}

var tanks = [];
var engines = [];
var fuel_freeze = nil;

var freeze_fuel_listener = nil;
var custom_initialized = 0;

_setlistener("/sim/signals/fdm-initialized", func {
  if (freeze_fuel_listener == nil)
  {
    freeze_fuel_listener = setlistener("/sim/freeze/fuel", func(n) { fuel_freeze = n.getBoolValue() }, 1);
  }
  engines = props.globals.getNode("engines", 1).getChildren("engine");
  foreach (var e; engines) {
    e.getNode("fuel-consumed-lbs", 1).setDoubleValue(0);
    e.getNode("out-of-fuel", 1).setBoolValue(0);
  }
  # do the following stuff once only
  if (custom_initialized)
    return;
  custom_initialized = 1;
  foreach (var t; props.globals.getNode("/consumables/fuel", 1).getChildren("tank")) {
    if (!t.getAttribute("children"))
      continue;           # skip native_fdm.cxx generated zombie tanks

    append(tanks, t);
    t.initNode("selected", 1, "BOOL");
  }
  print("BV-170 Custom Fuel Engine Initialized.");
  call(loop, [] );
});
