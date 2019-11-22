---
title: Variational Mixture of Normalizing Flows
author: Guilherme Grijó Pen Freitas Pires
logo: '`\includegraphics[width=0.2\textwidth]{figures/logo_ist.jpg}`{=latex}'
toc: true
---
# Introduction and Motivation

## Introduction and Motivation

\begin{fitemize}{0pt}{25pt}
\onslide<1->{\item Goal of this work: \bluebold{mixture of flexible distributions}.}
\onslide<2->{\item Two questions:}
    \begin{fitemize}{15pt}{25pt}
        \onslide<3->{\item What should the \bluebold{mixture components} be?}
        \onslide<4->{\item How should their \bluebold{parameters} be \bluebold{estimated}?}
    \end{fitemize}
\end{fitemize}

## Introduction and Motivation

\begin{fitemize}{0pt}{20pt}
\onslide<1->{\item Deep generative models: an active area of research}
    \begin{fitemize}{15pt}{15pt}
        \onslide<2->{\item \bluebold{Implicit distributions}: Generative adversarial networks
            \mycite{GAN}, Variational Autoencoder \mycite{vaepaper}
            \begin{fitemize}{10pt}{15pt}
                \item No explicit access to the density function \end{fitemize}}
        \onslide<3->{\item \bluebold{Explicit distributions}: Normalizing flows \mycite{shakir_nf}
            \begin{fitemize}{20pt}{15pt}
                \item Explicit access to the density function
                \item No approach to introduce discrete structure (multi-modality)
            \end{fitemize}}
    \end{fitemize}
\end{fitemize}

## Outline

\begin{fitemize}{0pt}{12pt}
\onslide<1->{\item Mixture Models}
\onslide<2->{\item Normalizing Flows}
    \onslide<3->{\begin{fitemize}{12pt}{12pt}
        \item The chosen family for the mixture model components \end{fitemize}}
\onslide<4->{\item Variational Inference}
    \onslide<5->{\begin{fitemize}{12pt}{12pt}
        \item The chosen framework for estimating the parameters of the proposed model\end{fitemize}}
\onslide<6->{\item Variational Mixture of Normalizing Flows}
\onslide<7->{\item Experiments and results}
\onslide<8->{\item Conclusions and future work}
\end{fitemize}

# Mixture Models

## Mixture Models: Mixture of Gaussians

\centering
\onslide<1->{\includegraphics[width=0.475\textwidth]{figures/mog_observed.png}}
\hfill
\onslide<2->{\includegraphics[width=0.475\textwidth]{figures/mog.png}}

## Mixture Models: Definition

\begin{fitemize}{10pt}{10pt}
    \onslide<1->{\item Mixture model: used to model data that contains \bluebold{subgroups}.}
    \onslide<2->{\item \q{Subgroup-conditional} distributions (typically) in the same family}
\end{fitemize}
\centering 
\onslide<3->{\includegraphics[width=0.3\textwidth]{figures/selector-mixture.png}}

## Mixture Models: Joint

For $N$ data points, $X = \{ \bm{x_i} : i = 1, 2, ..., N \}$, and hidden
variables $C = \{ c_i : i = 1, 2, ..., N \}$

\begin{minipage}[t]{0.4\textwidth}
  \centering
  \fbox{\includegraphics[width=0.8\textwidth]{figures/plate_diagram3.pdf}}
\end{minipage}
\begin{minipage}[t]{0.4\textwidth}
  \begin{align*}
  & p(\bm{x}, \bm{c}) = \\
  &= \prod_{i=1}^N \sum_{k=1}^K p_c(c_i = k) p_{\bm{x}|c}(\bm{x_i} | c_i = k, \theta_k) \\
  &= \prod_{i=1}^N \sum_{k=1}^K \pi_k p_{\bm{x}|c}(\bm{x_i} | c_i = k, \theta_k)
  \end{align*}
\end{minipage}

## Mixture Models: Difficult case

\centering
\includegraphics[width=0.5\textwidth]{figures/pinwheel_bw.png}

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

\onslide<3->{This can be \bluebold{optimized w.r.t. $\bm\theta$}, to approximate an \bluebold{arbitrary distribution}}

## Normalizing Flows: Change of Variables
\vspace{-20pt}
\onslide<1->{Requirements for feasibility}
\begin{fenumerate}{10pt}{30pt}
    \renewcommand{\theenumi}{\alph{enumi}}
    \onslide<2->{\item Base density - \bluebold{closed form} and \bluebold{easy to sample} from}
    \onslide<3->{\item \bluebold{Determinant} of the \bluebold{Jacobian} of $g$ - computationally cheap}
    \onslide<4->{\item \bluebold{Gradient} of $\det\Big(\frac{d}{d\bm{z}}g(\bm{z};\bm\theta)\Big)$ w.r.t $\bm\theta$ - computationally cheap}
\end{fenumerate}

## Normalizing Flows: Change of Variables

\begin{fitemize}{0pt}{30pt}
\onslide<1->{\item Normalizing Flows: \bluebold{composition} of several \q{good} transformations}
\onslide<2->{\item I.e., \bluebold{$g = h_{L-1} \circ h_{L-2} \circ ... \circ h_1 \circ h_0$}}
\onslide<3->{\item Applying the formula to $g$, and taking the logarithm:
\begin{align*}
    \log f_X(\bm{x}) = \log f_Z(g^{-1}(\bm{x})) - \sum_{\ell=0}^{L-1} \log \Big|\det\Big(\frac{d}{d\bm{x_{\ell}}}h_{\ell}(\bm{x_\ell})\Big) \Big|. \label{eq:nflowsfinal}
\end{align*}}
\end{fitemize}

## Normalizing Flows: Affine Coupling Layer

\begin{fitemize}{0pt}{10pt}
\onslide<1->{\item An example: Affine Coupling Layer \mycite{real-nvp}}
\onslide<2->{\item Splitting $\bm{z}$ into $(\bm{z_1}, \bm{z_2})$,}
\onslide<3->{\begin{align*}
    \begin{cases}
    \bm{x_1} &= \bm{z_1} \odot \exp\big(s(\bm{z_2})\big) + t(\bm{z_2}) \\
    \bm{x_2} &= \bm{z_2}.
    \end{cases}
\end{align*}}
\onslide<4->{\item The respective Jacobian matrix:
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
\end{fitemize}

# Variational Inference

## Variational Inference: Preamble

\begin{fitemize}{0pt}{10pt}
\onslide<1->{\item Joint probability distribution $p(\bm{x}, \bm{c})$.}
\onslide<2->{\item $\bm{x}$ is observed and $\bm{c}$ is latent.}
\onslide<3->{\item Inference about $\bm{c}$, given $\bm{x}$, by \bluebold{Bayes' Law}:
\begin{align*}
    p(\bm{c}|\bm{x}) &= \frac{p(\bm{x}|\bm{c})p(\bm{c})}{p(\bm{x})} \\
                     &= \frac{p(\bm{x}|\bm{c})p(\bm{c})}{\int p(\bm{x}|\bm{c}')p(\bm{c'}) d\bm{c'}}
\end{align*}
}
\onslide<4->{\item Problem: The integral is normally \bluebold{intractable}}
\onslide<5->{\begin{fitemize}{10pt}{0pt} \item \bluebold{Variational inference}:
an \bluebold{approximate inference} framework to overcome this intractability. \end{fitemize}}
\end{fitemize}

## Variational Inference: Goal

\centering
Given a family $q(\bm{c} ; \bm\lambda)$, find the parameters $\bm{\lambda^{*}}$ such that:
\begin{align*}
    \bm{\lambda^{*}} = \argmin_{\bm\lambda} KL(q(\bm{c}; \bm\lambda) || p(\bm{c} | \bm{x}))
\end{align*}

## Variational Inference: Goal

\centering
\includegraphics[width=0.7\textwidth]{figures/vi.pdf}

## Variational Inference: ELBO
\vspace{-20pt}
\begin{align*}
\onslide<1->{KL(q(\bm{c}) || p(\bm{c}|\bm{x})) &= \int q(\bm{c}) \log\frac{q(\bm{c})}{p(\bm{c}|\bm{x})} d\bm{c} \\}
\onslide<2->{&= \int q(\bm{c}) (\log q(\bm{c}) - \log p(\bm{c}|\bm{x})) d\bm{c} \\}
\onslide<3->{&= \int q(\bm{c}) (\log q(\bm{c}) - (\log p(\bm{x}, \bm{c}) - \log p(\bm{x}))) d\bm{c} \\}
\onslide<4->{&= {\color{blue} \mathbb{E}_q [\log q(\bm{c})] - \mathbb{E}_q [\log p(\bm{x}, \bm{c})]} + {\color{green} \log p(\bm{x})} \\}
\end{align*}

## Variational Inference: ELBO
\vspace{-20pt}
\begin{align*}
\onslide<2-> \overbrace{ \onslide<1->
KL(q(\bm{c}) || p(\bm{c}|\bm{x}))
\onslide<2-> }^{\geqslant 0} \onslide<1->
 + {\color{blue} \mathbb{E}_q [\log p(\bm{x}, \bm{c})] - \mathbb{E}_q [\log q(\bm{c})]}
&= {\color{green} \log p(\bm{x})} \\
\onslide<3->{{\color{blue} \mathbb{E}_q [\log p(\bm{x}, \bm{c})] - \mathbb{E}_q [\log q(\bm{c})]} &\leqslant {\color{green} \log p(\bm{x})}}
\end{align*}
\onslide<4->{
\begin{align*}
    \mbox{ELBO}(q) &= {\color{blue} \mathbb{E}_q [\log p(\bm{x}, \bm{c})] - \mathbb{E}_q [\log q(\bm{c})]} \\
            &= \mathbb{E}_q [\log p(\bm{x}|\bm{c})] + \mathbb{E}_q [\log p(\bm{c})] - \mathbb{E}_q [\log q(\bm{c})]
\end{align*}}

# Variational Mixture of Normalizing Flows

## VMoNF: Introduction
\onslide<1->{Is it possible to \bluebold{combine} the ideas from the previous sections,
to obtain a mixture of flexible models?}

## VMoNF: Definition

\begin{fitemize}{0pt}{20pt}
    \onslide<1->{\item Mixture of K normalizing flows}
    \onslide<2->{\item Variable $c_i$ selects the component for sample $\bm{x}_i$}
    \onslide<3->{\item $p(c|\bm{x})$ is unknown.}
    \begin{fitemize}{10pt}{10pt}
        \onslide<4->{\item Approximate it with $q(c|\bm{x})$: \bluebold{neural network}}
    \end{fitemize}
    \onslide<5->{\item Recall $ELBO(q) = \mathbb{E}_q [\log p(\bm{x}|c)] + \mathbb{E}_q [\log p(c)] - \mathbb{E}_q [\log q(\c)]$}
    \onslide<6->{\item The components $p(\bm{x}|c)$ are \bluebold{normalizing flows}}
    \onslide<7->{\item Optimize the ELBO, by \bluebold{jointly} learning the variational posterior and
the generative components.}
\end{fitemize}

## VMoNF: Overview

\centering
\includegraphics[width=0.7\textwidth]{figures/overview.pdf}

## VMoNF: Experiments - Pinwheel (5 wings)

\centering
\onslide<1->{\includegraphics[width=0.475\textwidth]{figures/original_pinwheel.png}}
\hfill
\onslide<2->{\includegraphics[width=0.475\textwidth]{figures/trained_pinwheel.png}}

## VMoNF: Experiments - Pinwheel (3 wings)

\centering
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

\begin{fitemize}{0pt}{20pt}
    \onslide<1->{\item Similar work is being pursued and published in prominent venues: \mycite{RAD}, \mycite{semisuplearning_nflows}}
    \onslide<2->{\item Investigate the effect of a consistency loss regularization term}
    \onslide<3->{\item Weight-sharing between components}
    \onslide<4->{\item Balance between complexities}
    \onslide<5->{\item (Controlled) component anihilation}
\end{fitemize}

##

\centering
Thank you!
