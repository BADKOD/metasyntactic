﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Numerics;

namespace Euler.Problems
{
    class Problem10 : Problem
    {
        public void run()
        {
            BigInteger result = 0;
            foreach (var v in Prime.Generator)
            {
                if (v >= 2000000)
                {
                    break;
                }
                result += v;
            }

            if (result != 142913828922) {
                throw new Exception();
            }
        }
    }
}
