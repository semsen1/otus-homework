<?php

namespace App\Http\Controllers;

use App\Actions\SolveQuadraticEquation;
use Illuminate\Http\Request;

class EquationController extends Controller
{
    protected SolveQuadraticEquation $solver;
    public function __construct(SolveQuadraticEquation $solver)
    {
        $this->solver = $solver;
    }
    public function solve(float $a, float $b, float $c): array|false
    {
        return $this->solver->solve($a, $b, $c);
    }
}
