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
#pragma clang diagnostic ignored "-Wabsolute-value"

static inline CGFloat acosCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? acosf(value)   : acos(value);   }
static inline CGFloat asinCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? asinf(value)   : asin(value);   }
static inline CGFloat atanCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? atanf(value)   : atan(value);   }
static inline CGFloat atan2CG(CGFloat y, CGFloat x)    { return sizeof(CGFloat) == 4 ? atan2f(y, x)   : atan2(y, x);   }
static inline CGFloat cosCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? cosf(value)    : cos(value);    }
static inline CGFloat sinCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? sinf(value)    : sin(value);    }
static inline CGFloat tanCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? tanf(value)    : tan(value);    }

static inline CGFloat acoshCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? acoshf(value)  : acosh(value);  }
static inline CGFloat asinhCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? asinhf(value)  : asinh(value);  }
static inline CGFloat atanhCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? atanhf(value)  : atanh(value);  }
static inline CGFloat coshCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? coshf(value)   : cosh(value);   }
static inline CGFloat sinhCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? sinhf(value)   : sinh(value);   }
static inline CGFloat tanhCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? tanhf(value)   : tanh(value);   }

static inline CGFloat expCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? expf(value)    : exp(value);    }
static inline CGFloat exp2CG(CGFloat value)            { return sizeof(CGFloat) == 4 ? exp2f(value)   : exp2(value);   }
static inline CGFloat expm1CG(CGFloat value)           { return sizeof(CGFloat) == 4 ? expm1f(value)  : expm1(value);  }

static inline CGFloat logCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? logf(value)    : log(value);    }
static inline CGFloat log10CG(CGFloat value)           { return sizeof(CGFloat) == 4 ? log10f(value)  : log10(value);  }
static inline CGFloat log2CG(CGFloat value)            { return sizeof(CGFloat) == 4 ? log2f(value)   : log2(value);   }
static inline CGFloat log1pCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? log1pf(value)  : log1p(value);  }
static inline CGFloat logbCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? logbf(value)   : logb(value);   }

static inline CGFloat modfCG(CGFloat v, CGFloat *i)    { return sizeof(CGFloat) == 4 ? modff(v, (float *)i) : modf(v, (double *)i); }
static inline CGFloat ldexpCG(CGFloat v, int n)        { return sizeof(CGFloat) == 4 ? ldexpf(v, n)   : ldexp(v, n);   }
static inline CGFloat frexpCG(CGFloat v, int *exp)     { return sizeof(CGFloat) == 4 ? frexpf(v, exp) : frexp(v, exp); }

static inline int ilogbCG(CGFloat value)               { return sizeof(CGFloat) == 4 ? ilogbf(value)  : ilogb(value);  }
static inline CGFloat scalbnCG(CGFloat v, int n)       { return sizeof(CGFloat) == 4 ? scalbnf(v, n)  : scalbn(v, n);  }
static inline CGFloat scalblnCG(CGFloat v, long int n) { return sizeof(CGFloat) == 4 ? scalblnf(v, n) : scalbln(v, n); }
static inline CGFloat fabsCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? fabsf(value)   : fabs(value);   }
static inline CGFloat cbrtCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? cbrtf(value)   : cbrt(value);   }
static inline CGFloat hypotCG(CGFloat x, CGFloat y)    { return sizeof(CGFloat) == 4 ? hypotf(x, y)   : hypot(x, y);   }
static inline CGFloat powCG(CGFloat x, CGFloat y)      { return sizeof(CGFloat) == 4 ? powf(x, y)     : pow(x, y);     }
static inline CGFloat sqrtCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? sqrtf(value)   : sqrt(value);   }

static inline CGFloat erfCG(CGFloat value)             { return sizeof(CGFloat) == 4 ? erff(value)    : erf(value);    }
static inline CGFloat erfcCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? erfcf(value)   : erfc(value);   }

static inline CGFloat ceilCG(CGFloat value)            { return sizeof(CGFloat) == 4 ? ceilf(value)   : ceil(value);   }
static inline CGFloat floorCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? floorf(value)  : floor(value);  }
static inline CGFloat nearbyintCG(CGFloat value)       { return sizeof(CGFloat) == 4 ? nearbyintf(value) : nearbyint(value); }
static inline long int rintCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? rintf(value)   : rint(value);   }
static inline CGFloat lrintCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? lrintf(value)  : lrint(value);  }
static inline CGFloat roundCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? roundf(value)  : round(value);  }
static inline long int lroundCG(CGFloat value)         { return sizeof(CGFloat) == 4 ? lroundf(value) : lround(value); }

static inline CGFloat truncCG(CGFloat value)           { return sizeof(CGFloat) == 4 ? truncf(value)  : trunc(value);  }
static inline CGFloat fmodCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fmodf(x, y)    : fmod(x, y);  }
static inline CGFloat remainderCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? remainderf(x, y) : remainder(x, y); }
static inline CGFloat remquoCG(CGFloat x, CGFloat y, int *n) { return sizeof(CGFloat) == 4 ? remquof(x, y, n) : remquo(x, y, n); }
static inline CGFloat copysignCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? copysignf(x, y) : copysign(x, y); }

static inline CGFloat nanCG(const char *tagp)          { return sizeof(CGFloat) == 4 ? nanf(tagp)     : nan(tagp);     }
static inline CGFloat nextafterCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? nextafterf(x, y) : nextafter(x, y); }
static inline CGFloat nexttowardCG(CGFloat x, CGFloat y) { return sizeof(CGFloat) == 4 ? nexttowardf(x, y) : nexttoward(x, y); }
static inline CGFloat fdimCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fdimf(x, y)    : fdim(x, y);    }
static inline CGFloat fmaxCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fmaxf(x, y)    : fmax(x, y);    }
static inline CGFloat fminCG(CGFloat x, CGFloat y)     { return sizeof(CGFloat) == 4 ? fminf(x, y)    : fmin(x, y);    }
static inline CGFloat fmaCG(CGFloat x, CGFloat y, CGFloat z) { return sizeof(CGFloat) == 4 ? fmaf(x, y, z) : fma(x, y, z); }

static inline CGFloat exp10CG(CGFloat v)               { return sizeof(CGFloat) == 4 ? __exp10f(v)    : __exp10(v);    }

#pragma clang diagnostic pop
