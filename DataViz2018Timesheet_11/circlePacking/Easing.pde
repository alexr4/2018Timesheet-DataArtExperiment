
//easing model
static class NormalEasing
{
  // ==================================================
  // Easing Equations by Robert Penner : http://robertpenner.com/easing/
  // http://www.timotheegroleau.com/Flash/experiments/easing_function_generator.htm
  // Based on ActionScript implementation by gizma : http://gizma.com/easing/
  // Processing implementation by Bonjour, Interactive Lab
  // soit time le temps actuelle ou valeur x à l'instant t;
  // soit start la position x de départ;
  // soit end l'increment de s donnant la position d'arrivee a = s + e;
  // soit duration la durée de l'opération
  // ==================================================
  // Linear
  static float linear(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return constrain(inc*time/duration + start, 0.0, 1.0);
  }

  // Quadratic
  static float inQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return constrain(inc * time * time + start, 0.0, 1.0);
  }

  static float outQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return constrain(-inc * time * (time - 2) + start, 0.0, 1.0);
  }

  static float inoutQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return constrain(inc/2 * time * time + start, 0.0, 1.0);
    } else
    {
      time--;
      return constrain(- inc/2 * (time * (time - 2) - 1) + start, 0.0, 1.0);
    }
  }

  //Cubic
  static float inCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return constrain(inc * pow(time, 3) + start, 0.0, 1.0);
  }

  static float outCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return constrain(inc * (pow(time, 3) + 1) + start, 0.0, 1.0);
  }

  static float inoutCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return constrain(inc/2 * pow(time, 3) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return constrain(inc/2 * (pow(time, 3) + 2) + start, 0.0, 1.0);
    }
  }

  //Quatric
  static float inQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return constrain(inc * pow(time, 4) + start, 0.0, 1.0);
  }

  static float outQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return constrain(-inc * (pow(time, 4) - 1) + start, 0.0, 1.0);
  }

  static float inoutQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return constrain(inc/2 * pow(time, 4) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return constrain(-inc/2 * (pow(time, 4) - 2) + start, 0.0, 1.0);
    }
  }

  //Quintic
  static float inQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return constrain(inc * pow(time, 5) + start, 0.0, 1.0);
  }

  static float outQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return constrain(inc * (pow(time, 5) + 1) + start, 0.0, 1.0);
  }

  static float inoutQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return constrain(inc/2 * pow(time, 5) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return constrain(inc/2 * (pow(time, 5) + 2) + start, 0.0, 1.0);
    }
  }

  //Sinusoïdal
  static float inSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return constrain(-inc * cos(time/duration * HALF_PI) + inc + start, 0.0, 1.0);
  }

  static float outSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return constrain(inc * sin(time/duration * HALF_PI) + start, 0.0, 1.0);
  }

  static float inoutSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return constrain(-inc/2 * (cos(PI * time/duration) - 1) + start, 0.0, 1.0);
  }

  //Exponential
  static float inExp(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    //return constrain(inc * pow(2, 10 * (time/duration - 1)) + start;
    if (time <= 0)
    {
      return constrain(start, 0.0, 1.0);
    } else
    {
      return constrain(inc * pow(2, 10 * (time/duration-1)) + start, 0.0, 1.0);
    }
  }

  static float outExp(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    if (time >= 1.0)
    {
      return constrain(1.0, 0.0, 1.0);
    } else
    {
      return constrain(inc * (-pow(2, -10 * (time/duration)) + 1) + start, 0.0, 1.0);
    }
  }

  static float inoutExp(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return constrain(inc/2 * pow(2, 10 * (time-1)) + start, 0.0, 1.0);
    } else
    {
      time --;
      return constrain(inc/2 * (-pow(2, -10 * time) + 2) + start, 0.0, 1.0);
    }
  }

  //Circular
  static float inCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return constrain(-inc * (sqrt(1 - time * time) - 1) + start, 0.0, 1.0);
  }

  static float outCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return constrain(inc * sqrt(1 - time * time) + start, 0.0, 1.0);
  }

  static float inoutCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return constrain(-inc/2 * (sqrt(1 - time * time) - 1) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return constrain(inc/2 * (sqrt(1 - time * time) + 1) + start, 0.0, 1.0);
    }
  }
}
