// Copyright (C) 2016-2018 Yixuan Qiu <yixuan.qiu@cos.name>
//
// This Source Code Form is subject to the terms of the Mozilla
// Public License v. 2.0. If a copy of the MPL was not distributed
// with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#ifndef SPARSE_CHOLESKY_H
#define SPARSE_CHOLESKY_H

#include <Eigen/Core>
#include <Eigen/SparseCore>
#include <Eigen/SparseCholesky>
#include <stdexcept>
#include <spectra/Util/CompInfo.h>

namespace Spectra {


///
/// \ingroup MatOp
///
/// This class defines the operations related to Cholesky decomposition on a
/// sparse positive definite matrix, \f$B=LL'\f$, where \f$L\f$ is a lower triangular
/// matrix. It is mainly used in the SymGEigsSolver generalized eigen solver
/// in the Cholesky decomposition mode.
///
template <typename Scalar, int Uplo = Eigen::Lower, int Flags = 0, typename StorageIndex = int>
class SparseCholesky
{
private:
    typedef Eigen::Matrix<Scalar, Eigen::Dynamic, 1> Vector;
    typedef Eigen::Map<const Vector> MapConstVec;
    typedef Eigen::Map<Vector> MapVec;
    typedef Eigen::SparseMatrix<Scalar, Flags, StorageIndex> SparseMatrix;

    const int m_n;
    Eigen::SimplicialLLT<SparseMatrix, Uplo> m_decomp;
    int m_info;  // status of the decomposition

public:
    ///
    /// Constructor to create the matrix operation object.
    ///
    /// \param mat_ An **Eigen** sparse matrix object, whose type is
    /// `Eigen::SparseMatrix<Scalar, ...>`.
    ///
    SparseCholesky(const SparseMatrix& mat_) :
        m_n(mat_.rows())
    {
        if(mat_.rows() != mat_.cols())
            throw std::invalid_argument("SparseCholesky: matrix must be square");

        m_decomp.compute(mat_);
        m_info = (m_decomp.info() == Eigen::Success) ?
                 SUCCESSFUL :
                 NUMERICAL_ISSUE;
    }

    ///
    /// Returns the number of rows of the underlying matrix.
    ///
    int rows() const { return m_n; }
    ///
    /// Returns the number of columns of the underlying matrix.
    ///
    int cols() const { return m_n; }

    ///
    /// Returns the status of the computation.
    /// The full list of enumeration values can be found in \ref Enumerations.
    ///
    int info() const { return m_info; }

    ///
    /// Performs the lower triangular solving operation \f$y=L^{-1}x\f$.
    ///
    /// \param x_in  Pointer to the \f$x\f$ vector.
    /// \param y_out Pointer to the \f$y\f$ vector.
    ///
    // y_out = inv(L) * x_in
    void lower_triangular_solve(const Scalar* x_in, Scalar* y_out) const
    {
        MapConstVec x(x_in,  m_n);
        MapVec      y(y_out, m_n);
        y.noalias() = m_decomp.permutationP() * x;
        m_decomp.matrixL().solveInPlace(y);
    }

    ///
    /// Performs the upper triangular solving operation \f$y=(L')^{-1}x\f$.
    ///
    /// \param x_in  Pointer to the \f$x\f$ vector.
    /// \param y_out Pointer to the \f$y\f$ vector.
    ///
    // y_out = inv(L') * x_in
    void upper_triangular_solve(const Scalar* x_in, Scalar* y_out) const
    {
        MapConstVec x(x_in,  m_n);
        MapVec      y(y_out, m_n);
        y.noalias() = m_decomp.matrixU().solve(x);
        y = m_decomp.permutationPinv() * y;
    }
};


} // namespace Spectra

#endif // SPARSE_CHOLESKY_H
