//
//  NRMath.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2014-03-18
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#include <CoreGraphics/CGBase.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"

inline CGFloat acosCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? acosf(value)   : acos(value);   }
inline CGFloat asinCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? asinf(value)   : asin(value);   }
inline CGFloat atanCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? atanf(value)   : atan(value);   }
inline CGFloat atan2CG(CGFloat y, CGFloat x)    { return sizeof(CGFloat) == 4 ? atan2f(y, x)   : atan2(y, x);   }
inline CGFloat cosCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? cosf(value)    : cos(value);    }
inline CGFloat sinCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? sinf(value)    : sin(value);    }
inline CGFloat tanCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? tanf(value)    : tan(value);    }

inline CGFloat acoshCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? acoshf(value)  : acosh(value);  }
inline CGFloat asinhCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? asinhf(value)  : asinh(value);  }
inline CGFloat atanhCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? atanhf(value)  : atanh(value);  }
inline CGFloat coshCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? coshf(value)   : cosh(value);   }
inline CGFloat sinhCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? sinhf(value)   : sinh(value);   }
inline CGFloat tanhCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? tanhf(value)   : tanh(value);   }

inline CGFloat expCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? expf(value)    : exp(value);    }
inline CGFloat exp2CG(CGFloat value)            { return sizeof(CGFloat) == 4 ? exp2f(value)   : exp2(value);   }
inline CGFloat expm1CG(CGFloat value)           { return sizeof(CGFloat) == 4 ? expm1f(value)  : expm1(value);  }

inline CGFloat logCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? logf(value)    : log(value);    }
inline CGFloat log10CG(CGFloat value)           { return sizeof(CGFloat) == 4 ? log10f(value)  : log10(value);  }
inline CGFloat log2CG(CGFloat value)            { return sizeof(CGFloat) == 4 ? log2f(value)   : log2(value);   }
inline CGFloat log1pCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? log1pf(value)  : log1p(value);  }
inline CGFloat logbCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? logbf(value)   : logb(value);   }

inline CGFloat modfCG(CGFloat v, CGFloat *i)    { return sizeof(CGFloat) == 4 ? modff(v, (float *)i) : modf(v, (double *)i); }
inline CGFloat ldexpCG(CGFloat v, int n)        { return sizeof(CGFloat) == 4 ? ldexpf(v, n)   : ldexp(v, n);   }
inline CGFloat frexpCG(CGFloat v, int *exp)     { return sizeof(CGFloat) == 4 ? frexpf(v, exp) : frexp(v, exp); }

inline int ilogbCG(CGFloat value)               { return sizeof(CGFloat) == 4 ? ilogbf(value)  : ilogb(value);  }
inline CGFloat scalbnCG(CGFloat v, int n)       { return sizeof(CGFloat) == 4 ? scalbnf(v, n)  : scalbn(v, n);  }
inline CGFloat scalblnCG(CGFloat v, long int n) { return sizeof(CGFloat) == 4 ? scalblnf(v, n) : scalbln(v, n); }
inline CGFloat fabsCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? fabsf(value)   : fabs(value);   }
inline CGFloat cbrtCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? cbrtf(value)   : cbrt(value);   }
inline CGFloat hypotCG(CGFloat x, CGFloat y)    { return sizeof(CGFloat) == 4 ? hypotf(x, y)   : hypot(x, y);   }
inline CGFloat powCG(CGFloat x, CGFloat y)      { return sizeof(CGFloat) == 4 ? powf(x, y)     : pow(x, y);     }
inline CGFloat sqrtCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? sqrtf(value)   : sqrt(value);   }

inline CGFloat erfCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? erff(value)    : erf(value);    }
inline CGFloat erfcCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? erfcf(value)   : erfc(value);   }

inline CGFloat ceilCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? ceilf(value)   : ceil(value);   }
inline CGFloat floorCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? floorf(value)  : floor(value);  }
inline CGFloat nearbyintCG(CGFloat value)       { return sizeof(CGFloat) == 4 ? nearbyintf(value) : nearbyint(value); }
inline long int rintCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? rintf(value)   : rint(value);   }
inline CGFloat lrintCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? lrintf(value)  : lrint(value);  }
inline CGFloat roundCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? roundf(value)  : round(value);  }
inline long int lroundCG(CGFloat value)         { return sizeof(CGFloat) == 4 ? lroundf(value) : lround(value); }

inline CGFloat truncCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? truncf(value)  : trunc(value);  }
inline CGFloat fmodCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fmodf(x, y)    : fmod(x, y);  }
inline CGFloat remainderCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? remainderf(x, y) : remainder(x, y); }
inline CGFloat remquoCG(CGFloat x, CGFloat y, int *n) { return sizeof(CGFloat) == 4 ? remquof(x, y, n) : remquo(x, y, n); }
inline CGFloat copysignCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? copysignf(x, y) : copysign(x, y); }

inline CGFloat nanCG(const char *tagp)          { return sizeof(CGFloat) == 4 ? nanf(tagp)     : nan(tagp);     }
inline CGFloat nextafterCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? nextafterf(x, y) : nextafter(x, y); }
inline CGFloat nexttowardCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? nexttowardf(x, y) : nexttoward(x, y); }
inline CGFloat fdimCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fdimf(x, y)    : fdim(x, y);    }
inline CGFloat fmaxCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fmaxf(x, y)    : fmax(x, y);    }
inline CGFloat fminCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fminf(x, y)    : fmin(x, y);    }
inline CGFloat fmaCG(CGFloat x, CGFloat y, CGFloat z) { return sizeof(CGFloat) == 4 ? fmaf(x, y, z) : fma(x, y, z); }

inline CGFloat exp10CG(CGFloat v)               { return sizeof(CGFloat) == 4 ? __exp10f(v)    : __exp10(v);    }

#pragma clang diagnostic pop
