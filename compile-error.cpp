typedef long int		mp_size_t;
typedef unsigned int		mp_limb_t;
typedef int			mp_limb_signed_t;

#define GMP_LIMB_BITS                      32
#define GMP_NAIL_BITS                      0
#define GMP_NUMB_BITS     (GMP_LIMB_BITS - GMP_NAIL_BITS)

template<mp_size_t n>
class bigint {
public:
    static const mp_size_t N = n;

    mp_limb_t data[n] = {0};

    bigint() = default;
    bigint(const char* s); /// Initialize from a string containing an integer in decimal notation
};

template<mp_size_t n, const bigint<n>& modulus>
class Fp_model {
public:
    static const mp_size_t num_limbs = n;
    static const constexpr bigint<n>& mod = modulus;
    Fp_model() {};
    Fp_model(const bigint<n> &b);
};

template<mp_size_t n, const bigint<n>& modulus>
class Fp2_model {
public:
	typedef Fp_model<n, modulus> my_Fp;
	my_Fp c0, c1;
	Fp2_model() {};
	Fp2_model(const my_Fp& c0, const my_Fp& c1) : c0(c0), c1(c1) {};
	Fp2_model inverse() const;
};






const mp_size_t alt_bn128_q_bitcount = 254;
const mp_size_t alt_bn128_q_limbs = (alt_bn128_q_bitcount+GMP_NUMB_BITS-1)/GMP_NUMB_BITS;
extern bigint<alt_bn128_q_limbs> alt_bn128_modulus_q;

typedef Fp_model<alt_bn128_q_limbs, alt_bn128_modulus_q> alt_bn128_Fq;
typedef Fp2_model<alt_bn128_q_limbs, alt_bn128_modulus_q> alt_bn128_Fq2;


alt_bn128_Fq alt_bn128_coeff_b;
alt_bn128_Fq2 alt_bn128_twist;
alt_bn128_Fq2 alt_bn128_twist_coeff_b;

template<mp_size_t n, const bigint<n>& modulus>
Fp2_model<n, modulus> operator*(const Fp_model<n, modulus> &lhs, const Fp2_model<n, modulus> &rhs);

int main() {
	alt_bn128_coeff_b = alt_bn128_Fq("3");
	alt_bn128_twist = alt_bn128_Fq2(alt_bn128_Fq("9"), alt_bn128_Fq("1"));
	alt_bn128_twist_coeff_b = alt_bn128_coeff_b * alt_bn128_twist.inverse();
}

