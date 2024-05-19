<?php
declare(strict_types=1);
namespace Tests\Unit;

use App\Http\Controllers\EquationController;
use Tests\TestCase;

class EquationTest extends TestCase
{
    private EquationController $resolver;

    public function setUp(): void
    {
        parent::setUp();

        $this->resolver = $this->app->make('App\Http\Controllers\EquationController');
    }
    //x^2+1 = 0 no roots
    public function test_no_roots()
    {
        $resolve = $this->resolver->solve(1,0,1);
        $this->assertEquals(array(), $resolve);
    }

    //x^2-1 = 0 (x1=1, x2=-1)
    public function test_two_roots()
    {
        $resolve = $this->resolver->solve(1,0,-1);
        $this->assertEquals(array(1,-1), $resolve);
    }

    //x^2+2x+1 = 0 (x1= x2 = -1)
    public function test_one_roots()
    {
        $resolve = $this->resolver->solve(1,2,1);
        $this->assertEquals(array(-1), $resolve);
    }

    //coefficient a equals 0
    public function test_coefficient_a_equals_zero()
    {
        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Coefficient a cannot be zero');
        $this->resolver->solve(0,2,1);
    }

    //coefficient a equals string
    public function test_coefficients_type()
    {
        $this->expectException(\TypeError::class);
        $this->resolver->solve('a',2,1);
    }
    //coefficient a equals string not converts to double
    public function test_coefficients_strict_types()
    {
        $this->expectException(\TypeError::class);
        $this->resolver->solve('1',2,1);
    }
}
