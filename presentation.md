---
title: Variational Mixture of Normalizing Flows
author: Guilherme Grijó Pen Freitas Pires
logo: '`\includegraphics[width=0.2\textwidth]{figures/logo_ist.jpg}`{=latex}'
toc: true
---
# Introduction and Motivation

## Introduction and Motivation

\begin{itemize}
\onslide<1->{\item Deep generative models have been an active area of research, with promising
results.}
    \begin{itemize}
        \onslide<2->{\item \textbf{Implicit distributions}: Generative adversarial networks
            {\scriptsize \color{black!50} \autocites{GAN}}, Variational Autoencoder {\scriptsize \color{black!50} \autocites{vaepaper}}
            \begin{itemize} \item Don't allow explicit access to the density function \end{itemize}}
        \onslide<3->{\item \textbf{Explicit distributions}: Normalizing flows {\scriptsize \color{black!50} \autocites{shakir_nf}}
            \begin{itemize}
                \item Allow explicit access to the density function
                \item Lack an approach to introduce discrete structure (multi-modality) in the modelled
                distribution.
            \end{itemize}}
    \end{itemize}
\end{itemize}

## Introduction and Motivation: Goal

\begin{itemize}
\onslide<1->{\item The goal of this work was the development of a mixture of flexible distributions.}
\onslide<2->{\item This requires answering two questions:}
    \begin{itemize}
        \onslide<3->{\item What should be the \q{family} of the mixture components?}
        \onslide<4->{\item How should the mixture components' parameters be estimated?}
    \end{itemize}
\end{itemize}

## Outline

\begin{itemize}
\onslide<1->{\item Mixture Models}
\onslide<2->{\item Variational Inference}
    \onslide<3->{\begin{itemize} \item The chosen framework for estimating the parameters of the proposed model\end{itemize}}
\onslide<4->{\item Normalizing Flows}
    \onslide<5->{\begin{itemize} \item The chosen family for the mixture model components \end{itemize}}
\onslide<6->{\item Variational Mixture of Normalizing Flows}
\onslide<7->{\item Experiments and results}
\onslide<8->{\item Conclusions and future work}
\end{itemize}

# Mixture Models

## Mixture Models: Definition

\begin{itemize}
    \onslide<1->{\item A mixture model is used to model data that is assumed to contain subgroups.}
    \onslide<2->{\item Typically, it is assumed that the \q{subgroup-conditional} distributions
    belong to the same family, but have different parameters.}
    \onslide<3->{\item Formally, a mixture model's joint distribution (for a single instance $\bm{x}$) is given by:
        \begin{align*}
            p(\bm{x}, c) = p(\bm{x}|c) p(c),
        \end{align*} where $c$ is the latent variable that indexes the subgroup to which $\bm{x}$
        belongs}
\end{itemize}

## Mixture Models: Plate diagram

\centering
\includegraphics[width=0.7\textwidth]{figures/plate_diagram2.png}

## Mixture Models: Mixture of Gaussians

\centering
\includegraphics[width=0.7\textwidth]{figures/mog.png}


# Normalizing Flows

## Normalizing Flows: Change of Variables

\onslide<1->{Given
\begin{align*}
\begin{cases}
    \bm{z} \sim p(\bm{z}) \\
    \bm{x} = g(\bm{z}; \bm\theta)
\end{cases}
\end{align*}}
\onslide<2->{then:
\begin{align*}
    f_X(\bm{x}) &= f_Z(g^{-1}(\bm{x};\bm\theta))\Big|\det\Big(\frac{d}{d\bm{x}}g^{-1}(\bm{x};\bm\theta)\Big)\Big| \\
    &= f_Z(g^{-1}(\bm{x};\bm\theta))\Big|\det\Big(\frac{d}{d\bm{z}}g(\bm{z};\bm\theta) \bigg{|}_{\bm{z} = g^{-1}(\bm{x};\bm\theta)}\Big)\Big|^{-1}
\end{align*}}

\onslide<3->{This can be optimized w.r.t. $\bm\theta$, so as to approximate
an arbitrary distribution}

## Normalizing Flows: Change of Variables

\onslide<1->{The described in the previous slide can be useful if}
\begin{itemize}
    \onslide<2->{\item The base density has a closed form expression and is easy to sample from}
    \onslide<3->{\item The determinant of the Jacobian of $g$ is computationally cheap - not the case, in general}
    \onslide<4->{\item The gradient of the determinant of the Jacobian of $g$ w.r.t $\bm\theta$ is computationally cheap}
\end{itemize}

## Normalizing Flows: Change of Variables

\onslide<1->{The framework of Normalizing Flows consists of composing several transformations
that fulfill the three listed conditions.}

\onslide<2->{I.e., the function $g$ is a composition of $L$ functions $h_\ell$, $\ell = 0, 1, ..., L-1$.}
\onslide<3->{Applying the formula to $g$, and taking the logarithm, yields:
\begin{align*}
    \log f_X(\bm{x}) = \log f_Z(g^{-1}(\bm{x})) - \sum_{\ell=0}^{L-1} \log \Big|\det\Big(\frac{d}{d\bm{x_{\ell}}}h_{\ell}(\bm{x_\ell})\Big) \Big|. \label{eq:nflowsfinal}
\end{align*}}

## Normalizing Flows: Affine Coupling Layer

An example of such a transformation is the Affine Coupling Layer
{\scriptsize \autocites{real-nvp}}.

\onslide<1->{Splitting $\bm{z}$ into $(\bm{z_1}, \bm{z_2})$,}
\onslide<2->{\begin{align*}
    \begin{cases}
    \bm{x_1} &= \bm{z_1} \odot \exp\big(s(\bm{z_2})\big) + t(\bm{z_2}) \\
    \bm{x_2} &= \bm{z_2}.
    \end{cases}
\end{align*}}
\onslide<3->{This transformation has the following Jacobian matrix:
\begin{align*}
    J_{f(z)} =
        \begin{tikzpicture}[decoration=brace, baseline=-\the\dimexpr\fontdimen22\textfont2\relax ]
            \matrix (m) [matrix of math nodes,left delimiter=[,right delimiter={]}, ampersand replacement=\&] {
                \mbox{\Large$\frac{\partial \bm{x_1}}{\partial \bm{z_1}}$} \& \mbox{\Large$\frac{\partial \bm{x_1}}{\partial \bm{z_2}}$} \\
                \mbox{\Large$\frac{\partial \bm{x_2}}{\partial \bm{z_1}}$} \& \mbox{\Large$\frac{\partial \bm{x_2}}{\partial \bm{z_2}}$} \\
            };
        \end{tikzpicture}
    =
        \begin{tikzpicture}[decoration=brace, baseline=-\the\dimexpr\fontdimen22\textfont2\relax ]
            \matrix (m) [matrix of math nodes,left delimiter=[,right delimiter={]}, ampersand replacement=\&] {
                \mbox{diag}\Big(\exp\big(s(\bm{z_2})\big)\Big) \& \mbox{\Large$\frac{\partial \bm{x_1}}{\partial \bm{z_2}}$} \\
                \mbox{\Large$\bm{0}$} \& \mbox{\Large$I$} \\
            };
        \end{tikzpicture}
\end{align*}
}

# Variational Inference

## Variational Inference: Preamble

\onslide<1->{Consider a joint probability distribution $p(\bm{x}, \bm{z})$.}
\onslide<2->{Suppose $\bm{x}$ is observed and $\bm{z}$ is latent.}
\onslide<3->{%
If we want to infer the most probable values of $\bm{z}$, given $\bm{x}$, by Bayes' Law:
\begin{align*}
    p(\bm{z}|\bm{x}) &= \frac{p(\bm{x}|\bm{z})p(\bm{z})}{p(\bm{x})} \\
                     &= \frac{p(\bm{x}|\bm{z})p(\bm{z})}{\int p(\bm{x}|\bm{z}')p(\bm{z'}) d\bm{z'}}
\end{align*}
}
\onslide<4->{\textbf{Problem}: The integral in the denominator is intractable for most
interesting models.
}
\onslide<5->{\begin{itemize} \item Variational inference is an approximate
inference framework, that can be used to overcome this intractability. \end{itemize}}

## Variational Inference: Goal

Given a parametric family of distributions $q(\bm{z} ; \bm\lambda)$,  find the parameters $\bm\lambda$
that minimize the Kullback-Leibler divergence between $q(\bm{z} ; \bm\lambda)$ and
$p(\bm{z}|\bm{x})$

## Variational Inference: ELBO

\begin{align*}
\onslide<1->{KL(q||p) &= \int q(\bm{z}) \log\frac{q(\bm{z})}{p(\bm{z})} d\bm{z} \\}
\onslide<2->{&= \int q(\bm{z}) (\log q(\bm{z}) - \log p(\bm{z}|\bm{x})) d\bm{z} \\}
\onslide<3->{&= \int q(\bm{z}) (\log q(\bm{z}) - (\log p(\bm{x}, \bm{z}) - \log p(\bm{x}))) d\bm{z} \\}
\onslide<4->{&= \mathbb{E}_q [\log q(\bm{z})] - \mathbb{E}_q [\log p(\bm{x}, \bm{z})] + \log p(\bm{x})}
\end{align*}

\onslide<5->
Which yields the lower bound (ELBO):
\begin{align*}
    ELBO(q) &= \mathbb{E}_q [\log p(\bm{x}, \bm{z})] - \mathbb{E}_q [\log q(\bm{z})] \\
            &= \mathbb{E}_q [\log p(\bm{x}|\bm{z})] + \mathbb{E}_q [\log p(\bm{z})] - \mathbb{E}_q [\log q(\bm{z})]
\end{align*}

# Variational Mixture of Normalizing Flows

## VMoNF: Introduction
\onslide<1->{Is it possible to combine the ideas from the previous sections,
to obtain a mixture of flexible models?}

## VMoNF: Definition

Recall the ELBO:
\begin{align*}
    ELBO(q) &= \mathbb{E}_q [\log p(\bm{x}|\bm{z})] + \mathbb{E}_q [\log p(\bm{z})] - \mathbb{E}_q [\log q(\bm{z})]
\end{align*}

. . .

Let the variational posterior $q(z|x)$ be parameterized by a neural network.

. . .

We optimize this objective, by \textbf{jointly} learning the variational posterior and
the generative components.

## VMoNF: Overview

\centering
\includegraphics[width=0.7\textwidth]{figures/train_overview.png}

## VMoNF: Experiments - Pinwheel (5 wings)

\centering
\onslide<1->{\includegraphics[width=0.475\textwidth]{figures/original_pinwheel.png}}
\hfill
\onslide<2->{\includegraphics[width=0.475\textwidth]{figures/trained_pinwheel.png}}

## VMoNF: Experiments - Pinwheel (3 wings)

Trainining Animation

## VMoNF: Experiments - 2 Circles

\centering
\onslide<1->{\includegraphics[width=0.475\textwidth]{figures/original_2_circles.png}}
\hfill
\onslide<2->{\includegraphics[width=0.475\textwidth]{figures/trained_2_circles_2.png}}

## VMoNF: Experiments - 2 Circles (semi supervised)

\centering
\onslide<1->{\includegraphics[width=0.475\textwidth]{figures/labeled_2_circles.png}}
\hfill
\onslide<2->{\includegraphics[width=0.475\textwidth]{figures/trained_2_circles_semisup.png}
{\scriptsize Note: 32 labeled points, 1024 unlabeled points}}

## VMoNF: Experiments - MNIST

\centering
\includegraphics[width=0.7\textwidth]{figures/trained_mnist.png}

# Conclusions

## Conclusions and Future Work

\begin{itemize}
    \onslide<1->{\item Similar work is being pursued and published in prominent venues: \autocites{RAD}{semisuplearning_nflows}}
    \onslide<2->{\item Formally describe the reasons why the model fails in cases like the 2 circles $\to$ Topology}
        \onslide<3->{\begin{itemize} \item Investigate the effect of a consistency loss regularization term \end{itemize}}
    \onslide<4->{\item Weight-sharing between components}
    \onslide<5->{\item Balance between complexities}
    \onslide<6->{\item (Controlled) component anihilation}
\end{itemize}

##

Thank you!
