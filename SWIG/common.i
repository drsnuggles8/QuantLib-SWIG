
/*
 Copyright (C) 2000, 2001, 2002 RiskMap srl

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it under the
 terms of the QuantLib license.  You should have received a copy of the
 license along with this program; if not, please email ferdinando@ametrano.net
 The license is also available online at http://quantlib.org/html/license.html

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

// $Id$

#ifndef quantlib_common_i
#define quantlib_common_i

%include stl.i
%include exception.i

%{
// generally useful classes
using QuantLib::Error;
using QuantLib::Handle;
using QuantLib::RelinkableHandle;
using QuantLib::IntegerFormatter;
using QuantLib::DoubleFormatter;
using QuantLib::StringFormatter;
%}

#if defined(SWIGRUBY) || defined(SWIGMZSCHEME) || defined(SWIGGUILE)
%rename("null?") isNull;
#endif
template <class T>
class Handle {
  private:
    Handle();
  public:
    #if defined(SWIGRUBY) || defined(SWIGMZSCHEME) || defined(SWIGGUILE)
    bool isNull();
    #elif defined(SWIGPYTHON)
    %extend {
        bool __nonzero__() {
            return !(self->isNull());
        }
    }
    #endif
};

#if defined(SWIGRUBY)
%rename("linkTo!") linkTo;
#elif defined(SWIGMZSCHEME) || defined(SWIGGUILE)
%rename("link-to!") linkTo;
#endif
template <class T>
class RelinkableHandle {
  public:
    void linkTo(const Handle<T>&);
    #if defined(SWIGRUBY) || defined(SWIGMZSCHEME) || defined(SWIGGUILE)
    bool isNull();
    #elif defined(SWIGPYTHON)
    %extend {
        bool __nonzero__() {
            return !(self->isNull());
        }
    }
    #endif
};


// import opaque values from the scripting language API

#if defined(SWIGPYTHON)
%typemap(in) PyObject* { $1 = $input; };
#endif

#if defined(SWIGRUBY)
%typemap(in) VALUE { $1 = $input; };
#endif

#if defined(SWIGMZSCHEME)
%typemap(in) Scheme_Object* { $1 = $input; };
#endif

#if defined(SWIGGUILE)
%typemap(in) SCM { $1 = $input; };
#endif


// typemap a C++ type to integers in the scripting language

%define MapToInteger(Type)
#if defined(SWIGPYTHON)

%typemap(in) Type {
    if (PyInt_Check($input))
        $1 = Type(PyInt_AsLong($input));
    else
        SWIG_exception(SWIG_TypeError,"int expected");
};

%typemap(out) Type {
    $result = PyInt_FromLong(long($1));
};

#elif defined(SWIGRUBY)

%typemap(in) Type {
    if (FIXNUM_P($input))
        $1 = Type(FIX2INT($input));
    else
        SWIG_exception(SWIG_TypeError,"not an integer");
};

%typemap(out) Type {
    $result = INT2NUM(int($1));
};

#elif defined(SWIGMZSCHEME)

%typemap(in) Type {
    if (SCHEME_INTP($input))
        $1 = Type(SCHEME_INT_VAL($input));
    else
        SWIG_exception(SWIG_TypeError,"int expected");
};

%typemap(out) Type {
    $result = scheme_make_integer_value(int($1));
};

#elif defined(SWIGGUILE)

%typemap(in) Type {
    $1 = Type(gh_scm2int($input));
};

%typemap(out) Type {
    $result = gh_int2scm(int($1));
};

#endif
%enddef


// typemap a C++ type to strings in the scripting language

%define MapToString(Type,TypeFromString,TypeToString)
#if defined(SWIGPYTHON)

%typemap(in) Type {
    if (PyString_Check($input)) {
        std::string s(PyString_AsString($input));
        try {
            $1 = TypeFromString(s);
        } catch (Error&) {
            SWIG_exception(SWIG_TypeError,"Type" " expected");
        }
    } else {
        SWIG_exception(SWIG_TypeError,"Type" " expected");
    }
};

%typemap(out) Type {
    $result = PyString_FromString(TypeToString($1).c_str());
};

#elif defined(SWIGRUBY)

%typemap(in) Type {
    if (TYPE($input) == T_STRING) {
        std::string s(STR2CSTR($input));
        try {
            $1 = TypeFromString(s);
        } catch (Error&) {
            SWIG_exception(SWIG_TypeError, "not a " "Type");
        }
    } else {
        SWIG_exception(SWIG_TypeError, "not a " "Type");
    }
};

%typemap(out) Type {
    $result = rb_str_new2(TypeToString($1).c_str());
};

#elif defined(SWIGMZSCHEME)

%typemap(in) Type {
    if (SCHEME_STRINGP($input)) {
        std::string s(SCHEME_STR_VAL($input));
        try {
            $1 = TypeFromString(s);
        } catch (Error&) {
            SWIG_exception(SWIG_TypeError, "Type" " expected");
        }
    } else {
        SWIG_exception(SWIG_TypeError, "Type" " expected");
    }
};

%typemap(out) Type {
    $result = scheme_make_string(TypeToString($1).c_str());
};

#elif defined(SWIGGUILE)

%typemap(in) Type (char* temp) {
    if (gh_string_p($input)) {
        temp = gh_scm2newstr($input, NULL);
        std::string s(temp);
        if (temp) scm_must_free(temp);
        try {
            $1 = TypeFromString(s);
        } catch (Error&) {
            SWIG_exception(SWIG_TypeError, "Type" " expected");
        }
    } else {
        SWIG_exception(SWIG_TypeError, "Type" " expected");
    }
};

%typemap(out) Type {
    $result = gh_str02scm(TypeToString($1).c_str());
};

#endif
%enddef


// Pass an object by value in MzScheme or Guile
%define PassByValue(T)
#if defined(SWIGMZSCHEME)
%typemap(in) T {
    $1 = *((T*) SWIG_MustGetPtr($input,$1_descriptor,$argnum));
}
#elif defined(SWIGGUILE)
%typemap(in) T {
    $1 = *((T*) SWIG_Guile_MustGetPtr($input,$1_descriptor,
                                      $argnum,FUNC_NAME));
}
#endif
%enddef

// Return an object by value in MzScheme or Guile
%define ReturnByValue(T)
#if defined(SWIGMZSCHEME)
%typemap(out) T {
    $result = SWIG_MakePtr(new T($1), $&1_descriptor);
}
#elif defined(SWIGGUILE)
%typemap(out) T {
    $result = SWIG_Guile_MakePtr(new T($1), $&1_descriptor);
}
#endif
%enddef

#endif