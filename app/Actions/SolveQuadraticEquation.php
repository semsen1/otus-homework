<?php
declare(strict_types=1);

namespace App\Actions;

class SolveQuadraticEquation
{
    /**
     * @throws \Exception
     */
    public function solve(float $a, float $b, float $c): array|false
    {
        // PHP_FLOAT_EPSILON = 2.2204460492503E-16
        if ($a < PHP_FLOAT_EPSILON && $a > -PHP_FLOAT_EPSILON) {
            throw new \Exception('Coefficient a cannot be zero');
        }

        $d = pow($b, 2) - (4 * $a * $c);
        if ($d < -PHP_FLOAT_EPSILON) {

            return [];
        } else {
            $x1 = (-$b + sqrt($d)) / (2 * $a);
            $x2 = (-$b - sqrt($d)) / (2 * $a);
        }

        if ($d < PHP_FLOAT_EPSILON && $d > -PHP_FLOAT_EPSILON) {
            return [$x1];
        }
        return [$x1, $x2];

    }
}
//http://127.0.0.1/api/test/1.000200701000/2.000100011010001/1.0001
