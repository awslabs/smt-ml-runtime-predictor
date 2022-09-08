# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

for i in {0..10}
do
	./collect_features.sh cvc5 1 $i true
done
