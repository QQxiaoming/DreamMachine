#ifndef INFERENCE_CLIENT_H
#define INFERENCE_CLIENT_H

#include "inference_types.h"

class InferenceClient
{
public:
    InferResult run(const InferRequestParams &params) const;
};

#endif // INFERENCE_CLIENT_H
