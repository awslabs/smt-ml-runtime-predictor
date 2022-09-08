# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

for i in {0..10}
do
	./collect_labels.sh cvc5 $i true
done
